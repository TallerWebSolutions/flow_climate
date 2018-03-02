# frozen_string_literal: true

Fabricator(:demand) do
  project
  created_date { Faker::Date.backward }
  demand_type 0
  class_of_service 0
  demand_id { Faker::Internet.domain_suffix }
  assignees_count 1
  effort { Faker::Number.decimal }
end
