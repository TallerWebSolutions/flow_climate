# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project, except: %i[demands_csv demands_in_projects search_demands_by_flow_status]
  before_action :assign_demand, only: %i[edit update show synchronize_jira destroy]

  def new
    @demand = Demand.new(project: @project, project_result: @project_result)
  end

  def create
    @demand = Demand.new(demand_params.merge(project: @project))
    return render :new unless @demand.save

    ComputeDemandUpdateJob.perform_later(@project.current_team.id, @demand.id) if @demand.valid?
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def destroy
    DemandsRepository.instance.full_demand_destroy!(@demand)
    render 'demands/destroy.js.erb'
  end

  def edit
    respond_to { |format| format.js }
  end

  def update
    @demand.update(demand_params)
    ComputeDemandUpdateJob.perform_later(@project.current_team.id, @demand.id) if @demand.valid?
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
    Jira::ProcessJiraIssueJob.perform_later(jira_account, @project, @demand.demand_id)
    flash[:notice] = t('general.enqueued')
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def demands_csv
    @demands_in_csv = Demand.where(id: params['demands_ids'].split(',')).kept.finished.order(end_date: :desc)
    attributes = %w[id demand_id demand_type class_of_service effort_downstream effort_upstream created_date commitment_date end_date]
    demands_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @demands_in_csv.each { |demand| csv << demand.csv_array }
    end
    respond_to { |format| format.csv { send_data demands_csv, filename: "demands-#{Time.zone.now}.csv" } }
  end

  def demands_in_projects
    projects = Project.where(id: params[:projects_ids].split(','))
    @demands_count_per_week = DemandService.instance.quantitative_consolidation_per_week_to_projects(projects)
    @demands = DemandsRepository.instance.demands_per_projects(projects).order(end_date: :desc, commitment_date: :desc, created_date: :desc)
    assign_grouped_demands_informations(@demands)
    respond_to { |format| format.js { render file: 'demands/demands_list.js.erb' } }
  end

  def search_demands_by_flow_status
    if params[:demands_ids].present?
      filtered_demands = build_demands_query(params[:demands_ids].split(',').map(&:strip).map(&:to_i))
      @demands = Demand.where(id: filtered_demands.map(&:id)).order(end_date: :desc, commitment_date: :desc, created_date: :desc)
      assign_grouped_demands_informations(@demands)
    else
      @demands = []
    end
    respond_to { |format| format.js { render file: 'demands/search_demands_by_flow_status.js.erb' } }
  end

  private

  def demand_params
    params.require(:demand).permit(:demand_id, :demand_type, :downstream, :manual_effort, :class_of_service, :assignees_count, :effort_upstream, :effort_downstream, :created_date, :commitment_date, :end_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_demand
    @demand = Demand.find(params[:id])
  end

  def assign_grouped_demands_informations(demands)
    @grouped_delivered_demands = demands.grouped_end_date_by_month if params[:grouped_by_month] == 'true'
    @grouped_customer_demands = demands.grouped_by_customer if params[:grouped_by_customer] == 'true'
  end

  def build_demands_query(array_of_demands_ids)
    return DemandsRepository.instance.not_started_demands(array_of_demands_ids) if params[:not_started] == 'true'
    return DemandsRepository.instance.committed_demands(array_of_demands_ids) if params[:wip] == 'true'
    return DemandsRepository.instance.demands_finished(array_of_demands_ids) if params[:delivered] == 'true'

    Demand.where(id: array_of_demands_ids)
  end
end
