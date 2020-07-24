# frozen_string_literal: true

class ProjectRiskAlertsRepository
  include Singleton

  def group_projects_risk_colors(projects, risk_type)
    ProjectRiskAlert.joins(:project_risk_config)
                    .where('project_risk_alerts.created_at = (SELECT MAX(created_at) FROM project_risk_alerts inner_alerts WHERE inner_alerts.project_id = project_risk_alerts.project_id AND inner_alerts.project_risk_config_id = project_risk_alerts.project_risk_config_id)')
                    .where(project_id: projects.map(&:id))
                    .where(project_risk_configs: { risk_type: risk_type })
                    .order(Arel.sql('project_risk_alerts.alert_color'))
                    .group(:alert_color).count
  end
end
