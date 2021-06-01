# frozen_string_literal: true

Fabricator(:demand_effort) do
  demand
  demand_transition
  item_assignment

  effort_value { 10 }

  start_time_to_computation { Time.zone.now }
  finish_time_to_computation { Time.zone.now }
end
