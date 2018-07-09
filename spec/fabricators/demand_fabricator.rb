# frozen_string_literal: true

Fabricator(:demand) do
  project
  demand_title { Faker::FunnyName.two_word_name }
  created_date { Faker::Date.backward }
  demand_type 0
  class_of_service 0
  demand_id { Random.new.rand(3000..1_000_000) }
  assignees_count 1
  effort_downstream { Faker::Number.decimal }
  effort_upstream { Faker::Number.decimal }
end
