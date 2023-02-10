# frozen_string_literal: true

class DemandsController < DemandsListController
  before_action :user_gold_check

  before_action :assign_demand, only: %i[edit update show synchronize_jira synchronize_azure destroy destroy_physically score_research]

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    read_demand_children

    compute_flow_efficiency
    compute_stream_percentages
    lead_time_breakdown
  end

  def edit; end

  def update
    @demand.update(demand_params)
    build_demands_list
    build_demands_objects

    if @demand.valid?
      flash[:notice] = I18n.t('general.updated.success')
      redirect_to company_demand_path(@company, @demand)
    else
      flash[:error] = "#{I18n.t('general.updated.error')} | #{@demand.errors.full_messages.join(' | ')}"
    end
  end

  def destroy
    @demand.discard
    assign_dates_to_query
    build_demands_list
    assign_consolidations

    redirect_to company_demands_path
  end

  def synchronize_jira
    jira_account = @company.jira_accounts.first
    demand_url = company_demand_url(@demand.project.company, @demand)
    Jira::ProcessJiraIssueJob.perform_later(jira_account, @demand.project, @demand.external_id, current_user.email, current_user.full_name, demand_url)
    flash[:notice] = I18n.t('general.enqueued')
    redirect_to company_demand_path(@company, @demand)
  end

  def synchronize_azure
    azure_account = @company.azure_account
    demand_url = company_demand_url(@demand.project.company, @demand)
    azure_project = @demand.product.azure_product_config.azure_team.azure_project
    Azure::AzureItemSyncJob.perform_later(@demand.external_id, azure_account, azure_project, current_user.email, current_user.full_name, demand_url)
    flash[:notice] = I18n.t('general.enqueued')
    redirect_to company_demand_path(@company, @demand)
  end

  def demands_csv
    demands = Demand.where(id: params[:demands_ids].split(','))
    demands_in_csv = demands.order(end_date: :desc)
    attributes = %w[id portfolio_unit current_stage project_id project_name external_id demand_title demand_type class_of_service demand_score effort_downstream effort_upstream leadtime created_date commitment_date end_date]
    demands_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      demands_in_csv.each { |demand| csv << demand.csv_array }
    end
    respond_to { |format| format.csv { send_data demands_csv, filename: "demands-#{Time.zone.now}.csv" } }
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
    @demands = []
    build_search_for_demands if object_type.present? && params[:flow_object_id].present?

    @paged_demands = @demands.page(page_param) if @demands.present?

    assign_consolidations

    render 'demands/index'
  end

  def demands_charts
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def demand_efforts
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  private

  def read_demand_children
    @demand_blocks = @demand.demand_blocks.includes([:blocker]).includes([:unblocker]).includes([:stage]).order(:block_time)
    @paged_demand_blocks = @demand_blocks.page(params[:page])
    @demand_transitions = @demand.demand_transitions.includes([:stage]).order(:last_time_in)
    @demand_comments = @demand.demand_comments.includes([:team_member]).order(:comment_date)
    @demand_efforts = @demand.demand_efforts.order(:start_time_to_computation)
    read_tasks
  end

  def read_tasks
    @tasks_list = @demand.tasks.kept.order(created_date: :desc)
    @paged_tasks = @tasks_list.page(params['page'])
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  def build_search_for_demands
    demandable = object_type.constantize.find(flow_object_id)

    @demand_fitness = params[:demand_fitness]
    @demand_state = params[:demand_state]
    @demand_type = @company.work_item_types.where('name ILIKE :type_name', type_name: "%#{params[:demand_type]}%").first if params[:demand_type].present?

    @demands = if @demand_fitness == 'overserved'
                 demandable.overserved_demands[:value]
               elsif @demand_fitness == 'underserved'
                 demandable.underserved_demands[:value]
               elsif @demand_fitness == 'f4p'
                 demandable.fit_for_purpose_demands[:value]
               elsif @demand_state == 'discarded'
                 demandable.demands.discarded
               elsif @demand_state == 'not_discarded'
                 demandable.demands.kept
               elsif @demand_type.present?
                 demandable.demands.where(work_item_type: @demand_type)
               elsif @demand_state == 'delivered'
                 demandable.demands.finished_until_date(Time.zone.now)
               elsif @demand_state == 'backlog'
                 Demand.where(id: demandable.demands.not_started(Time.zone.now).map(&:id))
               elsif @demand_state == 'upstream'
                 Demand.where(id: demandable.upstream_demands.map(&:id))
               elsif @demand_state == 'downstream'
                 demandable.demands.in_wip(Time.zone.now)
               elsif @demand_state == 'unscored'
                 demandable.demands.unscored_demands
               else
                 demandable.demands
               end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength

  def flow_object_id
    @flow_object_id ||= params[:flow_object_id]&.to_s || @company.id
  end

  def object_type
    @object_type ||= params[:object_type] || 'Company'
  end

  def build_demands_objects
    @demands_ids = @paged_demands.map(&:id)
    @demands = @paged_demands.except(:limit, :offset)
  end

  def compute_flow_efficiency
    @queue_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.total_queue_time, @demand.total_touch_time)
    @touch_percentage = 100 - @queue_percentage
  end

  def compute_stream_percentages
    @upstream_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.effort_upstream, @demand.effort_downstream)
    @downstream_percentage = 100 - @upstream_percentage
  end

  def build_demands_list
    @demands = []
    build_search_for_demands

    @paged_demands = @demands.page(page_param) if @demands.present?
  end

  def demand_params
    params.require(:demand).permit(:team_id, :product_id, :customer_id, :external_id, :downstream, :manual_effort, :effort_upstream, :effort_downstream, :created_date, :commitment_date, :end_date, :demand_score, :external_url, :object_type, :flow_object_id, :demand_state, :demand_fitness)
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
    params['start_date'].to_date if params['start_date'].present?
  end

  def end_date_to_query
    params['end_date'].to_date if params['end_date'].present?
  end
end
