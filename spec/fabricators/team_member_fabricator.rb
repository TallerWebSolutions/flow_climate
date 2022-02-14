# frozen_string_literal: true

Fabricator(:team_member) do
  company
  user
  name { Faker::Name.name.gsub(/\W/, '') }
  monthly_payment { Faker::Number.number }
  start_date { 2.days.ago }
  end_date { Time.zone.today }
end
