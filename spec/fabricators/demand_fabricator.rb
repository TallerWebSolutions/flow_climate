# frozen_string_literal: true

Fabricator(:demand) do
  work_item_type
  product
  project
  company
  team
  demand_title { Faker::FunnyName.two_word_name }
  created_date { 5.days.ago }
  class_of_service 0
  external_id { Random.new.rand(3000..1_000_000) }
  effort_downstream { 40 }
  effort_upstream { 50 }
end
