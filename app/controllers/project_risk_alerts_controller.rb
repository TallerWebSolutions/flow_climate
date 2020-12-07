# frozen_string_literal: true

class ProjectRiskAlertsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project

  def index
    @project_risk_alerts = @project.project_risk_alerts.order(created_at: :desc)
  end

  private

  def assign_project
    @project = Project.includes(:team).find(params[:project_id])
  end
end
