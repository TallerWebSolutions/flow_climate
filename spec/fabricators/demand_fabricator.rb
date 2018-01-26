# frozen_string_literal: true

Fabricator(:demand) do
  project_result
  demand_id { Faker::Internet.domain_suffix }
  effort { Faker::Number.decimal }
end
