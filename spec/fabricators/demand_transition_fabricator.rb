# frozen_string_literal: true

Fabricator(:demand_transition) do
  demand
  stage
  last_time_in { 3.days.ago }
  last_time_out { 1.month.from_now }
end
