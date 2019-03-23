# frozen_string_literal: true

Fabricator(:team_member) do
  team
  name { Faker::Name.name }
  monthly_payment { Faker::Number.decimal }
  hours_per_month { [100, 200, 300, 400, 203, 123, 44, 221, 453].sample }
  start_date { 2.days.ago }
  end_date { Time.zone.today }
end
