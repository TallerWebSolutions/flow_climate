# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_demand, only: %i[edit update show synchronize_pipefy]

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
    demand = Demand.find(params[:id])
    demand.destroy
    redirect_to company_project_path(@company, @project)
  end

  def edit; end

  def update
    if @demand.update(demand_params)
      ProjectResultsRepository.instance.update_project_results_for_demand!(@demand, @project.current_team) if @project.current_team.present?
      return redirect_to company_project_demand_path(@company, @project, @demand)
    end

    render :edit
  end

  def show
    @demand_blocks = @demand.demand_blocks.order(:block_time)
    @demand_transitions = @demand.demand_transitions.order(:last_time_in)
  end

  def synchronize_pipefy
    pipefy_response = Pipefy::PipefyApiService.request_card_details(@demand.demand_id)
    Pipefy::PipefyResponseReader.instance.update_card!(@project, @project.pipefy_config.team, @demand, pipefy_response)
    flash[:notice] = t('demands.sync.done')
    return redirect_to company_project_demand_path(@company, @project, @demand) if @demand.project == @project
    redirect_to company_project_path(@company, @project)
  end

  private

  def demand_params
    params.require(:demand).permit(:demand_id, :demand_type, :downstream, :class_of_service, :assignees_count, :effort_upstream, :effort_downstream, :created_date, :commitment_date, :end_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_demand
    @demand = Demand.find(params[:id])
  end
end
