# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_project, except: %i[demands_csv demands_in_projects search_demands_by_flow_status]
  before_action :assign_projects_for_queries, only: %i[demands_in_projects search_demands_by_flow_status]
  before_action :assign_demand, only: %i[edit update show synchronize_jira destroy]

  def new
    @demand = Demand.new(project: @project)
  end

  def create
    @demand = Demand.new(demand_params.merge(project: @project))
    return render :new unless @demand.save

    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def destroy
    @demand.discard
    render 'demands/destroy.js.erb'
  end

  def edit
    respond_to { |format| format.js }
  end

  def update
    @demand.update(demand_params)
    @updated_demand = DemandsList.find(@demand.id)
    render 'demands/update'
  end

  def show
    @demand_blocks = @demand.demand_blocks.order(:block_time)
    @demand_transitions = @demand.demand_transitions.order(:last_time_in)
    @queue_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.total_queue_time, @demand.total_touch_time)
    @touch_percentage = 100 - @queue_percentage
    @upstream_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.working_time_upstream, @demand.working_time_downstream)
    @downstream_percentage = 100 - @upstream_percentage
  end

  def synchronize_jira
    jira_account = Jira::JiraAccount.find_by(customer_domain: @project.project_jira_config.jira_account_domain)
    demand_url = company_project_demand_url(@demand.project.company, @demand.project, @demand)
    Jira::ProcessJiraIssueJob.perform_later(jira_account, @project, @demand.demand_id, current_user.email, current_user.full_name, demand_url)
    flash[:notice] = t('general.enqueued')
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def demands_csv
    @demands_in_csv = Demand.where(id: params['demands_ids'].split(',')).kept.order(end_date: :desc)
    attributes = %w[id current_stage demand_id demand_title demand_type class_of_service effort_downstream effort_upstream created_date commitment_date end_date]
    demands_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @demands_in_csv.each { |demand| csv << demand.csv_array }
    end
    respond_to { |format| format.csv { send_data demands_csv, filename: "demands-#{Time.zone.now}.csv" } }
  end

  def demands_in_projects
    filtered_demands = DemandsRepository.instance.demands_to_projects(@projects)
    @demands = build_limit_date_query(filtered_demands, 'week')
    @demands_count_per_week = DemandService.instance.quantitative_consolidation_per_week_to_projects(@projects)
    assign_consolidations

    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, 'week')

    respond_to { |format| format.js { render file: 'demands/demands_tab.js.erb' } }
  end

  def search_demands_by_flow_status
    @demands = query_demands(params[:period])

    build_grouping_query(@demands, params[:grouping])

    assign_consolidations
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, params[:grouping_period])

    respond_to { |format| format.js { render file: 'demands/search_demands_by_flow_status.js.erb' } }
  end

  private

  def query_demands(period)
    demands_to_projects = DemandsRepository.instance.demands_to_projects(@projects)
    demands = build_limit_date_query(demands_to_projects, period)
    demands = filter_text(demands)
    demands = build_flow_status_query(demands, params[:flow_status])
    demands = buld_demand_type_query(demands, params[:demand_type])
    build_class_of_service_query(demands, params[:demand_class_of_service])
  end

  def demand_params
    params.require(:demand).permit(:demand_id, :demand_type, :downstream, :manual_effort, :class_of_service, :assignees_count, :effort_upstream, :effort_downstream, :created_date, :commitment_date, :end_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_projects_for_queries
    @projects = Project.where(id: params[:projects_ids].split(','))
  end

  def assign_demand
    @demand = Demand.find(params[:id])
  end

  def build_limit_date_query(demands, period)
    bottom_date = bottom_date_limit_value(period)
    filtered_demands = demands
    filtered_demands = demands.where('(demands_lists.end_date IS NULL AND demands_lists.created_date >= :bottom_date) OR (demands_lists.end_date >= :bottom_date)', bottom_date: bottom_date) if bottom_date.present?

    filtered_demands.order('demands_lists.end_date DESC, demands_lists.commitment_date DESC, demands_lists.created_date DESC')
  end

  def build_grouping_query(demands, params_grouping)
    return if params[:grouping] == 'no_grouping'

    @grouped_delivered_demands = demands.grouped_end_date_by_month if params_grouping == 'grouped_by_month'
    @grouped_customer_demands = demands.grouped_by_customer if params_grouping == 'grouped_by_customer'
    @grouped_by_stage_demands = DemandTransitionsRepository.instance.summed_transitions_time_grouped_by_stage_demand_for(demands.map(&:id)) if params_grouping == 'grouped_by_stage'
  end

  def build_flow_status_query(demands, params_flow_status)
    filtered_demands = demands
    filtered_demands = filtered_demands.not_started if params_flow_status == 'not_started'
    filtered_demands = filtered_demands.in_wip if params_flow_status == 'wip'
    filtered_demands = filtered_demands.finished if params_flow_status == 'delivered'

    filtered_demands
  end

  def buld_demand_type_query(demands, params_demand_type)
    filtered_demands = demands
    filtered_demands = filtered_demands.feature if params_demand_type == 'feature'
    filtered_demands = filtered_demands.bug if params_demand_type == 'bug'
    filtered_demands = filtered_demands.chore if params_demand_type == 'chore'
    filtered_demands = filtered_demands.performance_improvement if params_demand_type == 'performance_improvement'
    filtered_demands = filtered_demands.ui if params_demand_type == 'ui'
    filtered_demands = filtered_demands.wireframe if params_demand_type == 'wireframe'
    filtered_demands
  end

  def build_class_of_service_query(demands, params_class_of_service)
    filtered_demands = demands
    filtered_demands = filtered_demands.standard if params_class_of_service == 'standard'
    filtered_demands = filtered_demands.expedite if params_class_of_service == 'expedite'
    filtered_demands = filtered_demands.fixed_date if params_class_of_service == 'fixed_date'
    filtered_demands = filtered_demands.intangible if params_class_of_service == 'intangible'
    filtered_demands
  end

  def filter_text(demands)
    return demands if params[:search_text].blank?

    demands.joins(project: :product).where('demand_title ILIKE :search_param OR demand_id ILIKE :search_param OR products.name ILIKE :search_param OR projects.name ILIKE :search_param', search_param: "%#{params[:search_text].downcase}%")
  end

  def bottom_date_limit_value(period)
    base_date = @projects.map(&:end_date).flatten.max
    base_date = Time.zone.now if @projects.blank? || @projects.map(&:status).flatten.include?('executing')
    TimeService.instance.limit_date_to_period(period, base_date)
  end

  def assign_consolidations
    @confidence_95_leadtime = Stats::StatisticsService.instance.percentile(95, @demands.map(&:leadtime_in_days))
    @confidence_80_leadtime = Stats::StatisticsService.instance.percentile(80, @demands.map(&:leadtime_in_days))
    @confidence_65_leadtime = Stats::StatisticsService.instance.percentile(65, @demands.map(&:leadtime_in_days))

    @total_queue_time = @demands.sum(&:total_queue_time)
    @total_touch_time = @demands.sum(&:total_touch_time)
  end
end
