# frozen_string_literal: true

Fabricator(:project) do
  company
  team
  name { Faker::Name.unique.name.gsub(/\W/, '') }
  start_date 2.months.ago
  end_date 2.months.from_now
  status 0
  project_type 0
  initial_scope 30
  value { Faker::Number.number }
  qty_hours { Faker::Number.number(digits: 3) }
  hour_value { Faker::Number.number(digits: 2) }
end
