# frozen_string_literal: true

Fabricator(:team_member) do
  team
  name { Faker::Name.name }
  monthly_payment { Faker::Number.decimal }
  hours_per_month { Faker::Number.decimal(0) }
end
