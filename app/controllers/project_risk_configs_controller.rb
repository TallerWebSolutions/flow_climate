# frozen_string_literal: true

class ProjectRiskConfigsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_project
  before_action :assign_project_risk_config, only: %i[activate deactivate destroy]

  def new
    @project_risk_config = ProjectRiskConfig.new(project: @project)
  end

  def create
    @project_risk_config = ProjectRiskConfig.new(project_risk_configs_params.merge(project: @project))
    return redirect_to company_project_path(@company, @project) if @project_risk_config.save

    render :new
  end

  def activate
    @project_risk_config.activate!
    redirect_to company_project_path(@company, @project)
  end

  def deactivate
    @project_risk_config.deactivate!
    redirect_to company_project_path(@company, @project)
  end

  def destroy
    @project_risk_config.destroy
    redirect_to company_project_path(@company, @project)
  end

  private

  def project_risk_configs_params
    params.require(:project_risk_config).permit(:risk_type, :low_yellow_value, :high_yellow_value)
  end

  def assign_project
    @project = Project.includes(:team).find(params[:project_id])
  end

  def assign_project_risk_config
    @project_risk_config = ProjectRiskConfig.find(params[:id])
  end
end
