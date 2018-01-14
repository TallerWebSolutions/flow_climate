# frozen_string_literal: true

class ProjectResultsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project

  def new
    @project_result = ProjectResult.new(project: @project)
  end

  def create
    @project_result = ProjectResult.new(project_result_params.merge(project: @project))
    return redirect_to company_project_path(@company, @project) if @project_result.save
    render :new
  end

  def destroy
    @project_result = ProjectResult.find(params[:id])
    @project_result.destroy
    redirect_to company_project_path(@company, @project)
  end

  private

  def project_result_params
    params.require(:project_result).permit(:result_date, :qty_hours_upstream, :qty_hours_downstream, :throughput, :qty_bugs_opened, :qty_bugs_closed, :qty_hours_bug, :leadtime, :histogram_first_mode, :histogram_second_mode)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
