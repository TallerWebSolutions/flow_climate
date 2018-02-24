# frozen_string_literal: true

Fabricator(:demand_transition) do
  stage
  demand
  last_time_in { Faker::Date.between(3.days.ago, 1.month.from_now) }
end
