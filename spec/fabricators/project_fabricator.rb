# frozen_string_literal: true

Fabricator(:project) do
  name { Faker::Project.name }
  start_date { 1.day.from_now }
  end_date { 1.week.from_now }
  status { 0 }
end
