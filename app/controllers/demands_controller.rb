# frozen_string_literal: true

class DemandsController < DemandsListController
  protect_from_forgery except: %i[demands_tab search_demands]

  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_demand, only: %i[edit update show synchronize_jira destroy destroy_physically score_research]
  before_action :assign_project, except: %i[demands_csv demands_tab search_demands show destroy destroy_physically score_research index demands_list_by_ids]

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
    @paged_demands = demands.order('demands.end_date DESC, demands.commitment_date DESC, demands.created_date DESC').page(page_param)
    @demands = @paged_demands.except(:limit, :offset)
    assign_consolidations

    respond_to { |format| format.js { render 'demands/search_demands' } }
  end

  def edit
    @paged_demands = demands.order('demands.end_date DESC, demands.commitment_date DESC, demands.created_date DESC').page(page_param)
    @demands_ids = @paged_demands.map(&:id)

    respond_to { |format| format.js { render 'demands/edit' } }
  end

  def update
    @demand.update(demand_params)
    @paged_demands = demands.order('demands.end_date DESC, demands.commitment_date DESC, demands.created_date DESC').page(page_param)
    @demands_ids = @paged_demands.map(&:id)
    @demands = @paged_demands.except(:limit, :offset)
    @unscored_demands = @project.demands.unscored_demands.order(external_id: :asc)

    respond_to { |format| format.js { render 'demands/update' } }
  end

  def show
    @demand_blocks = @demand.demand_blocks.order(:block_time)
    @paged_demand_blocks = @demand_blocks.page(params[:page])
    @demand_transitions = @demand.demand_transitions.order(:last_time_in)
    @demand_comments = @demand.demand_comments.order(:comment_date)

    compute_flow_efficiency
    compute_stream_percentages
    lead_time_breakdown
  end

  def index
    @paged_demands = @company.demands.order('end_date DESC, commitment_date DESC, created_date DESC').page(page_param)
    @demands = @paged_demands.except(:limit, :offset)
    @demands_ids = @demands.map(&:id)

    assign_dates_to_query
    assign_consolidations
  end

  def synchronize_jira
    jira_account = @company.jira_accounts.first
    demand_url = company_project_demand_url(@demand.project.company, @demand.project, @demand)
    Jira::ProcessJiraIssueJob.perform_later(jira_account, @project, @demand.external_id, current_user.email, current_user.full_name, demand_url)
    flash[:notice] = I18n.t('general.enqueued')
    redirect_to company_demand_path(@company, @demand)
  end

  def demands_csv
    @demands_in_csv = demands.kept.order(end_date: :desc)
    attributes = %w[id portfolio_unit current_stage project_id external_id demand_title demand_type class_of_service demand_score effort_downstream effort_upstream created_date commitment_date end_date]
    demands_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @demands_in_csv.each { |demand| csv << demand.csv_array }
    end
    respond_to { |format| format.csv { send_data demands_csv, filename: "demands-#{Time.zone.now}.csv" } }
  end

  def demands_tab
    assign_dates_to_query

    @discarded_demands = demands.discarded
    @demands = query_demands.kept
    @paged_demands = @paged_demands&.page(page_param)

    @demands_ids = @demands.map(&:id).split(',')

    assign_consolidations

    respond_to { |format| format.js { render 'demands/demands_tab' } }
  end

  def search_demands
    assign_dates_to_query

    @demands = query_demands
    @paged_demands = @demands.page(page_param)

    assign_consolidations

    render 'demands/index'
  end

  def destroy_physically
    flash[:error] = @demand.errors.full_messages.join(',') unless @demand.destroy

    respond_to { |format| format.js { render 'demands/destroy_physically' } }
  end

  def score_research
    ScoreMatrix.create(product: @demand.product) if @demand.product.score_matrix.blank?

    @demand_score_matrix = DemandScoreMatrix.new(user: current_user, demand: @demand)
    @percentage_answered = DemandScoreMatrixService.instance.percentage_answered(@demand)
    @current_position_in_backlog = "#{DemandScoreMatrixService.instance.current_position_in_backlog(@demand)}º"
    @backlog_total = DemandScoreMatrixService.instance.demands_list(@demand).count

    render 'demands/score_matrix/score_research'
  end

  def demands_list_by_ids
    @paged_demands = demands.page(page_param)
    assign_consolidations

    render 'demands/index'
  end

  private

  def demands_ids
    ids = session[params[:session_demands_key]]

    ids = params[:demands_ids] if ids.blank?
    ids&.split(',')
  end

  def compute_flow_efficiency
    @queue_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.total_queue_time, @demand.total_touch_time)
    @touch_percentage = 100 - @queue_percentage
  end

  def compute_stream_percentages
    @upstream_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.effort_upstream, @demand.effort_downstream)
    @downstream_percentage = 100 - @upstream_percentage
  end

  def demands
    @demands_ids = demands_ids
    @demands ||= Demand.where(id: @demands_ids)
  end

  def query_demands
    searched_demands = DemandService.instance.search_engine(demands, params[:demands_start_date], params[:demands_end_date], params[:search_text], params[:flow_status], params[:demand_type], params[:demand_class_of_service], params[:search_demand_tags]&.split(' '))
    searched_demands.order('demands.end_date DESC, demands.commitment_date DESC, demands.created_date DESC')
  end

  def demand_params
    params.require(:demand).permit(:team_id, :product_id, :customer_id, :external_id, :demand_type, :downstream, :manual_effort, :class_of_service, :effort_upstream, :effort_downstream, :created_date, :commitment_date, :end_date, :demand_score, :external_url)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_demand
    @demand = @company.demands.friendly.find(params[:id]&.downcase)
  end

  def lead_time_breakdown
    @lead_time_breakdown ||= DemandService.instance.lead_time_breakdown([@demand])
  end

  def assign_dates_to_query
    @start_date = start_date_to_query
    @end_date = end_date_to_query
  end

  def start_date_to_query
    return params['start_date'].to_date if params['start_date'].present?

    3.months.ago.to_date
  end

  def end_date_to_query
    return params['end_date'].to_date if params['end_date'].present?

    Time.zone.today
  end
end
