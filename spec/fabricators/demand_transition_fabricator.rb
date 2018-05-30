# frozen_string_literal: true

Fabricator(:demand_transition) do
  demand
  stage { |attrs| Fabricate(:stage, projects: [attrs[:demand].project]) }
  last_time_in { Faker::Date.between(3.days.ago, 1.month.from_now) }
  last_time_out { Faker::Date.between(1.month.from_now, 2.months.from_now) }
end
