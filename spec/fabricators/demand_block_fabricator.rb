# frozen_string_literal: true

Fabricator(:demand_block) do
  stage
  demand
  blocker { Fabricate :team_member }
  block_time Time.zone.now
end
