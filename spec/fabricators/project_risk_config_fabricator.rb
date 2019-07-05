# frozen_string_literal: true

Fabricator(:project_risk_config) do
  project
  risk_type { ProjectRiskConfig.risk_types.values.sample }
  high_yellow_value { Faker::Number.number }
  low_yellow_value { Faker::Number.number }
  active true
end
