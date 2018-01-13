# frozen_string_literal: true

Fabricator(:operation_result) do
  company
  result_date { Faker::Date.between(3.days.ago, 4.days.from_now) }
  people_billable_count { Faker::Number.decimal(0) }
  operation_week_value { Faker::Number.decimal(2) }
  available_hours { Faker::Number.decimal(0) }
  total_billable_hours { Faker::Number.decimal(0) }
  total_th { Faker::Number.decimal(0) }
  total_opened_bugs { Faker::Number.decimal(0) }
  total_accumulated_closed_bugs { Faker::Number.decimal(0) }
end
