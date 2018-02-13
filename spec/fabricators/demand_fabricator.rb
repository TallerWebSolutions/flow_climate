# frozen_string_literal: true

Fabricator(:demand) do
  project_result
  created_date { Faker::Date.backward }
  demand_id { Faker::Internet.domain_suffix }
  effort { Faker::Number.decimal }
end
