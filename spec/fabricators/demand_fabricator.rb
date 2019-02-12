# frozen_string_literal: true

Fabricator(:demand) do
  project
  company
  demand_title { Faker::FunnyName.two_word_name }
  created_date { 5.days.ago }
  commitment_date { 1.day.ago }
  end_date { Time.zone.now }
  demand_type 0
  downstream true
  class_of_service 0
  demand_id { Random.new.rand(3000..1_000_000) }
  assignees_count 1
  effort_downstream { 40 }
  effort_upstream { 50 }
end
