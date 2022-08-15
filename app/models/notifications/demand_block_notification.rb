# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_block_notifications
#
#  id              :bigint           not null, primary key
#  block_state     :integer          default("blocked"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  demand_block_id :integer          not null
#
# Indexes
#
#  index_demand_block_notifications_on_block_state      (block_state)
#  index_demand_block_notifications_on_demand_block_id  (demand_block_id)
#
# Foreign Keys
#
#  fk_rails_37865053c5  (demand_block_id => demand_blocks.id)
#

module Notifications
  class DemandBlockNotification < ApplicationRecord
    enum block_state: { blocked: 0, unblocked: 1 }

    belongs_to :demand_block
  end
end
