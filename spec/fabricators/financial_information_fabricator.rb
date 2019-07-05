# frozen_string_literal: true

Fabricator(:financial_information) do
  company
  finances_date { Time.zone.today }
  income_total { Faker::Number.number }
  expenses_total { Faker::Number.number }
end
