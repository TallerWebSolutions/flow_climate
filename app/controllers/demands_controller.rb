# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_demand, only: %i[edit update show synchronize_jira destroy destroy_physically]
  before_action :assign_project, except: %i[demands_csv demands_in_projects search_demands show destroy destroy_physically]
  before_action :assign_projects_for_queries, only: %i[demands_in_projects search_demands]

  def new
    @demand = Demand.new(project: @project)
  end

  def create
    @demand = Demand.new(demand_params.merge(project: @project, company: @company))
    return render :new unless @demand.save

    redirect_to company_demand_path(@company, @demand)
  end

  def destroy
    @demand.discard

    assign_dates_to_query

    @demands = DemandsList.kept.where(id: params[:demands_ids].split(','))
    build_grouping_query(@demands, params[:grouping])

    assign_consolidations
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, @start_date, @end_date, params[:grouping_period])

    respond_to { |format| format.js { render 'demands/search_demands' } }
  end

  def edit
    demands = Demand.where(id: params[:demands_ids])
    @demands_ids = demands.map(&:id)

    respond_to { |format| format.js { render 'demands/edit' } }
  end

  def update
    @demand.update(demand_params)
    demands = Demand.where(id: params[:demands_ids])
    @demands_ids = demands.map(&:id)
    @updated_demand = DemandsList.find(@demand.id)
    respond_to { |format| format.js { render 'demands/update' } }
  end

  def show
    @demand_blocks = @demand.demand_blocks.order(:block_time)
    @demand_transitions = @demand.demand_transitions.order(:last_time_in)
    @queue_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.total_queue_time, @demand.total_touch_time)
    @touch_percentage = 100 - @queue_percentage
    @upstream_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.effort_upstream, @demand.effort_downstream)
    @downstream_percentage = 100 - @upstream_percentage
    @demand_comments = @demand.demand_comments.order(:comment_date)
  end

  def synchronize_jira
    jira_account = @company.jira_accounts.first
    demand_url = company_project_demand_url(@demand.project.company, @demand.project, @demand)
    Jira::ProcessJiraIssueJob.perform_later(jira_account, @project, @demand.demand_id, current_user.email, current_user.full_name, demand_url)
    flash[:notice] = I18n.t('general.enqueued')
    redirect_to company_demand_path(@company, @demand)
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
    filtered_demands_list_view = DemandsRepository.instance.demands_created_before_date_to_projects(@projects)

    assign_dates_to_query

    @demands = build_date_query_and_order(filtered_demands_list_view, @start_date, @end_date)
    @demands_count_per_week = DemandService.instance.quantitative_consolidation_per_week_to_projects(@projects)
    @discarded_demands = DemandsRepository.instance.discarded_demands_to_projects(@projects)

    assign_consolidations

    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, @start_date, @end_date, 'week')

    respond_to { |format| format.js { render 'demands/demands_tab' } }
  end

  def search_demands
    assign_dates_to_query

    @demands = query_demands(@start_date, @end_date)

    build_grouping_query(@demands, params[:grouping])

    assign_consolidations

    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(@demands, @start_date, @end_date, params[:grouping_period])

    respond_to { |format| format.js { render 'demands/search_demands' } }
  end

  def destroy_physically
    flash[:error] = @demand.errors.full_messages.join(',') unless @demand.destroy

    respond_to { |format| format.js { render 'demands/destroy_physically' } }
  end

  private

  def assign_dates_to_query
    @start_date = start_date_to_query
    @end_date = end_date_to_query
  end

  def start_date_to_query
    return params['start_date'].to_date if params['start_date'].present?

    return [@projects&.map(&:start_date)&.min, 3.months.ago.to_date].max if @projects&.map(&:executing?).present?

    @projects&.map(&:start_date)&.min || Time.zone.today
  end

  def end_date_to_query
    return params['end_date'].to_date if params['end_date'].present?

    [@projects&.map(&:end_date)&.max, Time.zone.today].compact.min.to_date
  end

  def query_demands(start_date, end_date)
    demands_created_before_date_to_projects = DemandsRepository.instance.demands_created_before_date_to_projects(@projects)
    demands_list_view = build_date_query_and_order(demands_created_before_date_to_projects, start_date, end_date)
    demands_list_view = filter_text(demands_list_view)
    demands_list_view = build_flow_status_query(demands_list_view, params[:flow_status])
    demands_list_view = buld_demand_type_query(demands_list_view, params[:demand_type])
    build_class_of_service_query(demands_list_view, params[:demand_class_of_service])
  end

  def demand_params
    params.require(:demand).permit(:team_id, :demand_id, :demand_type, :downstream, :manual_effort, :class_of_service, :effort_upstream, :effort_downstream, :created_date, :commitment_date, :end_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_projects_for_queries
    @projects = Project.where(id: params[:projects_ids].split(','))
    @projects_ids = @projects.map(&:id)
  end

  def assign_demand
    @demand = Demand.friendly.find(params[:id]&.downcase)
  end

  def build_date_query_and_order(demands_list_view, start_date, end_date)
    prepared_query_demands = demands_list_view.includes(:project).includes(:demand)

    return prepared_query_demands unless start_date.present? && end_date.present?

    filtered_demands = prepared_query_demands.to_dates(start_date, end_date)

    filtered_demands.order('demands_lists.end_date DESC, demands_lists.commitment_date DESC, demands_lists.created_date DESC')
  end

  def build_grouping_query(demands, params_grouping)
    return if params[:grouping] == 'no_grouping'

    @grouped_delivered_demands = demands.grouped_end_date_by_month if params_grouping == 'grouped_by_month'
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

  def filter_text(demands_list_view)
    return demands_list_view.includes(:project) if params[:search_text].blank?

    demands_list_view.includes(:project).joins(:project).where('demands_lists.demand_title ILIKE :search_param OR demands_lists.demand_id ILIKE :search_param OR projects.name ILIKE :search_param', search_param: "%#{params[:search_text].downcase}%")
  end

  def assign_consolidations
    if @demands.present?
      @confidence_95_leadtime = Stats::StatisticsService.instance.percentile(95, @demands.finished_with_leadtime.map(&:leadtime_in_days))
      @confidence_80_leadtime = Stats::StatisticsService.instance.percentile(80, @demands.finished_with_leadtime.map(&:leadtime_in_days))
      @confidence_65_leadtime = Stats::StatisticsService.instance.percentile(65, @demands.finished_with_leadtime.map(&:leadtime_in_days))
      build_flow_informations
    else
      @confidence_95_leadtime = 0
      @confidence_80_leadtime = 0
      @confidence_65_leadtime = 0
      @total_queue_time = 0
      @total_touch_time = 0
      @average_queue_time = 0
      @average_touch_time = 0
      @avg_work_hours_per_demand = 0
    end
  end

  def build_flow_informations
    @total_queue_time = @demands.sum(&:total_queue_time).to_f / 1.hour
    @total_touch_time = @demands.sum(&:total_touch_time).to_f / 1.hour
    @average_queue_time = @total_queue_time / @demands.count
    @average_touch_time = @total_touch_time / @demands.count
    @avg_work_hours_per_demand = @demands.with_effort.sum(&:total_effort) / @demands.count
    build_block_informations
  end

  def build_block_informations
    @share_demands_blocked = @demands.count { |demand_list| demand_list.demand.demand_blocks.count.positive? }.to_f / @demands.count
  end
end
