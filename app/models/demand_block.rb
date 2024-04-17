# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_blocks
#
#  id                          :bigint           not null, primary key
#  active                      :boolean          default(TRUE), not null
#  block_reason                :string
#  block_time                  :datetime         not null
#  block_type                  :integer          default("coding_needed"), not null
#  block_working_time_duration :decimal(, )
#  discarded_at                :datetime
#  lock_version                :integer
#  unblock_reason              :string
#  unblock_time                :datetime
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  blocker_id                  :integer          not null
#  demand_id                   :integer          not null
#  risk_review_id              :integer
#  stage_id                    :integer
#  unblocker_id                :integer
#
# Indexes
#
#  index_demand_blocks_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_0c8fa8d3a7  (demand_id => demands.id)
#  fk_rails_11fee31fef  (blocker_id => team_members.id)
#  fk_rails_196a395613  (unblocker_id => team_members.id)
#  fk_rails_6c21b271de  (risk_review_id => risk_reviews.id)
#  fk_rails_d25cb2ae7e  (stage_id => stages.id)
#

class DemandBlock < ApplicationRecord
  include Discard::Model

  enum block_type: { coding_needed: 0, specification_needed: 1, waiting_external_supplier: 2, customer_low_urgency: 3, integration_needed: 4, customer_unavailable: 5, other_demand_dependency: 6, external_dependency: 7, other_demand_priority: 8, waiting_for_code_review: 9, budget_approval: 10, waiting_deploy_window: 11, infrastructure: 12, scope_changed: 13, waiting_approval: 14 }

  belongs_to :demand
  belongs_to :stage, optional: true
  belongs_to :blocker, class_name: 'TeamMember', inverse_of: :demand_blocks
  belongs_to :unblocker, class_name: 'TeamMember', inverse_of: :demand_blocks, optional: true
  belongs_to :risk_review, optional: true

  has_many :demand_block_notifications, dependent: :destroy, class_name: 'Notifications::DemandBlockNotification'

  validates :block_time, :block_type, presence: true

  default_scope { where(active: true) }

  scope :for_date_interval, ->(start_date, end_date) { where('((block_time <= :finish_time) AND (unblock_time >= :start_time)) OR (unblock_time IS NULL AND block_time <= :finish_time)', start_time: start_date, finish_time: end_date) }
  scope :open, -> { where(unblock_time: nil) }
  scope :closed, -> { where.not(unblock_time: nil) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { unscoped.where(active: false) }
  scope :for_active_projects, -> { joins(demand: :project).where(project: { status: Project.statuses[:executing] }) }
  scope :for_inactive_projects, -> { joins(demand: :project).where.not(project: { status: Project.statuses[:executing] }) }

  delegate :name, to: :blocker, prefix: true
  delegate :project_id, to: :demand, prefix: false

  before_save :update_computed_fields
  after_save :update_blocked_time_in_demand

  def csv_array
    [
      id,
      block_time&.iso8601,
      unblock_time&.iso8601,
      block_working_time_duration,
      demand.external_id
    ]
  end

  def to_hash
    { blocker_username: blocker.name, block_time: block_time, block_reason: block_reason, unblock_time: unblock_time }
  end

  def activate!
    update(active: true)
  end

  def deactivate!
    update(active: false)
  end

  def total_blocked_time
    return (unblock_time - block_time) if unblock_time.present?

    Time.zone.now - block_time
  end

  def stage_when_unblocked
    return nil if unblock_time.blank?

    demand.stage_at(unblock_time)
  end

  private

  def update_computed_fields
    end_time = unblock_time || Time.zone.now
    self.block_working_time_duration = TimeService.instance.compute_working_hours_for_dates(block_time, end_time)
    self.stage = demand.stage_at(block_time)
  end

  def update_blocked_time_in_demand
    demand.update(total_bloked_working_time: demand.demand_blocks.filter_map(&:block_working_time_duration).sum)
  end
end
