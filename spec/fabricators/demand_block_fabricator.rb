# frozen_string_literal: true

Fabricator(:demand_block) do
  demand
  demand_block_id 1
  blocker { Fabricate :team_member }
  block_time Time.zone.now
end
