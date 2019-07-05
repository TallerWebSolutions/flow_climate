# frozen_string_literal: true

Fabricator(:project_risk_alert) do
  project
  project_risk_config
  alert_color { ProjectRiskAlert.alert_colors.values.sample }
  alert_value { Faker::Number.number }
end
