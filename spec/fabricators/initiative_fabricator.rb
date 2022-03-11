# frozen_string_literal: true

Fabricator(:initiative) do
  company
  name { Faker::Company.name }
  start_date { 2.months.ago }
  end_date { 1.month.from_now }
end
