# frozen_string_literal: true

Fabricator(:demand_block_notification, from: 'Notifications::DemandBlockNotification') do
  demand_block
end
