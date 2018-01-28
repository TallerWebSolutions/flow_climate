# frozen_string_literal: true

Fabricator(:project_risk_config) do
  company
  risk_type { ProjectRiskConfig.risk_types.values.sample }
  high_yellow_value { Faker::Number.decimal }
  low_yellow_value { Faker::Number.decimal }
end
