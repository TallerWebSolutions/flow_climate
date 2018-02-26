# frozen_string_literal: true

Fabricator(:demand) do
  project
  project_result
  created_date { Faker::Date.backward }
  demand_type 0
  class_of_service 0
  demand_id { Faker::Internet.domain_suffix }
  effort { Faker::Number.decimal }
end
