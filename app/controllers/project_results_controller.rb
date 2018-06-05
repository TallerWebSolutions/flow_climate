# frozen_string_literal: true

class ProjectResultsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_project_result

  def show
    @demands = @project_result.demands.sort_by(&:result_date).reverse.group_by { |demand| [demand.result_date.to_date.cwyear, demand.result_date.to_date.month] }
  end

  private

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_project_result
    @project_result = ProjectResult.find(params[:id])
  end
end
