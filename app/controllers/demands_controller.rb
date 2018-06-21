# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_demand, only: %i[edit update show synchronize_pipefy destroy]

  def new
    @demand = Demand.new(project: @project, project_result: @project_result)
  end

  def create
    @demand = Demand.new(demand_params.merge(project: @project))
    return render :new unless @demand.save
    ProjectResultService.instance.compute_demand!(@project.current_team, @demand)
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def destroy
    DemandsRepository.instance.full_demand_destroy!(@demand)
    render 'demands/destroy.js.erb'
  end

  def edit; end

  def update
    if @demand.update(demand_params)
      ProjectResultService.instance.compute_demand!(@project.current_team, @demand) if @project.current_team.present?
      return redirect_to company_project_demand_path(@company, @project, @demand)
    end

    render :edit
  end

  def show
    @demand_blocks = @demand.demand_blocks.order(:block_time)
    @demand_transitions = @demand.demand_transitions.order(:last_time_in)
    @queue_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.total_queue_time, @demand.total_touch_time)
    @touch_percentage = 100 - @queue_percentage
    @upstream_percentage = Stats::StatisticsService.instance.compute_percentage(@demand.working_time_upstream, @demand.working_time_downstream)
    @downstream_percentage = 100 - @upstream_percentage
  end

  def synchronize_pipefy
    pipefy_response = Pipefy::PipefyApiService.request_card_details(@demand.demand_id)
    @demand = Pipefy::PipefyCardAdapter.instance.process_card_response!(@project.pipefy_config.team, @demand, pipefy_response)
    if @demand.blank? || @demand.valid?
      process_succeeded_sync
    else
      flash[:error] = @demand.errors.full_messages.join(', ')
      redirect_to company_project_demand_path(@company, @project, @demand)
    end
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

  def process_succeeded_sync
    flash[:notice] = t('demands.sync.done')
    return redirect_to company_project_demand_path(@company, @project, @demand) if @demand&.project == @project
    redirect_to company_project_path(@company, @project)
  end
end
