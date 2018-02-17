# frozen_string_literal: true

Fabricator(:project_result) do
  team
  project
  result_date Time.zone.today
  known_scope { Faker::Number.number(3) }
  qty_hours_upstream { Faker::Number.number(2) }
  qty_hours_downstream { Faker::Number.number(3) }
  qty_hours_bug { Faker::Number.number(2) }
  qty_bugs_closed { Faker::Number.number(3) }
  qty_bugs_opened { Faker::Number.number(2) }
  qty_bugs_opened { Faker::Number.number(2) }
  throughput { Faker::Number.number(3) }
  leadtime { Faker::Number.decimal(2) }
  flow_pressure { Faker::Number.decimal(2) }
  remaining_days { Faker::Number.decimal(0) }
  cost_in_month { Faker::Number.decimal(2) }
  average_demand_cost { Faker::Number.decimal(2) }
  available_hours { Faker::Number.decimal(2) }
end
