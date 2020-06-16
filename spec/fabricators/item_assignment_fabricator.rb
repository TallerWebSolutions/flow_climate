# frozen_string_literal: true

Fabricator(:item_assignment) do
  demand
  membership

  start_time { Time.zone.yesterday }
end
