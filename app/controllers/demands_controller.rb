# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_project_result
  before_action :assign_demand, only: %i[edit update]

  def new
    @demand = Demand.new
  end

  def create
    @demand = Demand.new(demand_params.merge(project: @project, project_result: @project_result))
    if @demand.save
      update_project_results(@demand)
      return redirect_to company_project_project_result_path(@company, @project, @project_result)
    end
    render :new
  end

  def destroy
    demand = Demand.find(params[:id])
    demand.destroy
    redirect_to company_project_project_result_path(@company, @project, @project_result)
  end

  def edit; end

  def update
    previous_date = @demand.end_date || @demand.created_date

    if @demand.update(demand_params)
      update_project_results(@demand, previous_date)
      return redirect_to company_project_project_result_path(@company, @project, @project_result)
    end

    render :edit
  end

  private

  def update_project_results(demand, previous_date = nil)
    if previous_date.present?
      ProjectResultsRepository.instance.update_result_for_date(@project, previous_date)
    end

    current_date = demand.end_date || demand.created_date
    ProjectResultsRepository.instance.update_result_for_date(@project, current_date)
  end

  def demand_params
    params.require(:demand).permit(:demand_id, :demand_type, :class_of_service, :effort, :created_date, :commitment_date, :end_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_project_result
    @project_result = ProjectResult.find(params[:project_result_id])
  end

  def assign_demand
    @demand = Demand.find(params[:id])
  end
end
