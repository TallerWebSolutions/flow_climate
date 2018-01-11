# frozen_string_literal: true

Fabricator(:financial_information) do
  company
  finances_date { Time.zone.today }
  income_total { Faker::Number.decimal }
  expenses_total { Faker::Number.decimal }
end
