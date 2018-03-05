# frozen_string_literal: true

Fabricator(:demand_block) do
  demand
  demand_block_id 1
  blocker_username { Faker::Internet.user_name }
  block_time Time.zone.now
  block_reason { Faker::Lorem.sentence }
end
