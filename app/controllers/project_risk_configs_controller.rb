# frozen_string_literal: true

class ProjectRiskConfigsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project

  def new
    @project_risk_config = ProjectRiskConfig.new(project: @project)
  end

  def create
    @project_risk_config = ProjectRiskConfig.new(project_risk_configs_params.merge(project: @project))
    return redirect_to company_project_path(@company, @project) if @project_risk_config.save
    render :new
  end

  private

  def project_risk_configs_params
    params.require(:project_risk_config).permit(:risk_type, :low_yellow_value, :high_yellow_value)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
