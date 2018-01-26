# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_project_result

  def new
    @demand = Demand.new
  end

  def create
    @demand = Demand.new(demand_params.merge(project_result: @project_result))
    return redirect_to company_project_project_result_path(@company, @project, @project_result) if @demand.save
    render :new
  end

  private

  def demand_params
    params.require(:demand).permit(:demand_id, :effort)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_project_result
    @project_result = ProjectResult.find(params[:project_result_id])
  end
end
