# frozen_string_literal: true

Fabricator(:company_settings) do
  company
  max_flow_pressure { Faker::Number.number(digits: 3) }
  max_active_parallel_projects { Faker::Number.number(digits: 1) }
end
