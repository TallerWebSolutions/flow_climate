# frozen_string_literal: true

Fabricator(:item_assignment) do
  demand
  team_member

  start_time { Time.zone.yesterday }
end
