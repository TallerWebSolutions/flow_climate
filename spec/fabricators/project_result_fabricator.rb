# frozen_string_literal: true

Fabricator(:project_result) do
  project
  result_date Time.zone.today
  known_scope { Faker::Number.decimal(0) }
  qty_hours_upstream { Faker::Number.decimal(0) }
  qty_hours_downstream { Faker::Number.decimal(0) }
  qty_hours_bug { Faker::Number.decimal(0) }
  qty_bugs_closed { Faker::Number.decimal(0) }
  qty_bugs_opened { Faker::Number.decimal(0) }
  throughput { Faker::Number.decimal(0) }
  leadtime { Faker::Number.decimal(2) }
end
