# frozen_string_literal: true

Fabricator(:project) do
  name { Faker::BossaNova.song }
  start_date { 1.day.from_now }
  end_date { 1.week.from_now }
  status 0
  project_type 0
  initial_scope 30
  value { Faker::Number.decimal }
  qty_hours { Faker::Number.decimal(0) }
  hour_value { Faker::Number.decimal(2) }
end
