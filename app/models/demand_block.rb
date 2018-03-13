# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_blocks
#
#  id                 :integer          not null, primary key
#  demand_id          :integer          not null
#  demand_block_id    :integer          not null
#  blocker_username   :string           not null
#  block_time         :datetime         not null
#  block_reason       :string           not null
#  unblocker_username :string
#  unblock_time       :datetime
#  unblock_reason     :string
#  block_duration     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_demand_blocks_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_id => demands.id)
#

class DemandBlock < ApplicationRecord
  belongs_to :demand

  validates :demand, :demand_id, :demand_block_id, :blocker_username, :block_time, :block_reason, presence: true

  before_update :update_computed_fields!

  private

  def update_computed_fields!
    self.block_duration = TimeService.instance.compute_working_hours_for_dates(block_time, unblock_time) if unblock_time.present?
  end
end
