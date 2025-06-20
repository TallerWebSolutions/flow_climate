# frozen_string_literal: true

# == Schema Information
#
# Table name: item_assignments
#
#  id                     :bigint           not null, primary key
#  assignment_for_role    :boolean          default(FALSE)
#  assignment_notified    :boolean          default(FALSE), not null
#  discarded_at           :datetime
#  finish_time            :datetime
#  item_assignment_effort :decimal(, )      default(0.0), not null
#  lock_version           :integer
#  pull_interval          :decimal(, )      default(0.0)
#  start_time             :datetime         not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  demand_id              :integer          not null
#  membership_id          :integer          not null
#
# Indexes
#
#  idx_on_demand_id_membership_id_start_time_573dd337cc  (demand_id,membership_id,start_time) UNIQUE
#  index_item_assignments_on_demand_id                   (demand_id)
#  index_item_assignments_on_membership_id               (membership_id)
#
# Foreign Keys
#
#  fk_rails_0af34c141e  (demand_id => demands.id)
#  fk_rails_6ab6a3b3a4  (membership_id => memberships.id)
#

class ItemAssignment < ApplicationRecord
  include Discard::Model

  self.locking_column = :lock_version

  belongs_to :demand
  belongs_to :membership

  has_many :demand_efforts, dependent: :destroy

  validates :demand, uniqueness: { scope: %i[membership start_time], message: I18n.t('item_assignment.validations.demand_unique') }

  scope :for_dates, ->(start_date, end_date) { where('(start_time <= :end_date::timestamp AND finish_time >= :start_date::timestamp) OR (start_time <= :end_date::timestamp AND finish_time IS NULL) OR (finish_time >= :start_date::timestamp AND :end_date::timestamp IS NULL) OR (start_time <= :start_date::timestamp AND finish_time IS NULL)', start_date: start_date, end_date: end_date) }
  scope :not_for_membership, ->(membership) { where.not('item_assignments.membership_id' => membership.id) }
  scope :open_assignments, -> { joins(:demand).where(finish_time: nil, demands: { end_date: nil, discarded_at: nil }) }

  delegate :team_member_name, to: :membership

  before_save :compute_assignment_effort
  before_save :compute_pull_interval

  def self.safe_destroy_each(assignments)
    destroyed_count = 0
    skipped_count = 0

    assignments.find_each do |assignment|
      assignment.destroy
      destroyed_count += 1
    rescue ActiveRecord::StaleObjectError
      Rails.logger.info("ItemAssignment #{assignment.id} already destroyed by another process - skipping")
      skipped_count += 1
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info("ItemAssignment #{assignment.id} already deleted - skipping")
      skipped_count += 1
    end

    Rails.logger.info("ItemAssignment batch destruction: #{destroyed_count} destroyed, #{skipped_count} skipped")
    { destroyed: destroyed_count, skipped: skipped_count }
  end

  def working_hours_until(beginning_time = nil, end_time = Time.zone.now)
    start_effort_time = [start_time, beginning_time].compact.max
    end_effort_time = [finish_time, end_time].compact.min

    TimeService.instance.compute_working_hours_for_dates(start_effort_time, end_effort_time, demand.project.company)
  end

  def stages_during_assignment
    demand.stages_at(start_time, finish_time)
  end

  def assigned_at
    demand.stage_at(start_time)
  end

  def previous_assignment
    return @previous_assignment if @previous_assignment.present?

    ordered_assignments = membership.item_assignments.where('start_time < :start_time', start_time: start_time).order(:start_time)
    ordered_assignments -= [self] if persisted?

    @previous_assignment = ordered_assignments.last
  end

  def membership_open_assignments
    membership.item_assignments.open_assignments
  end

  def pairing_assignment?(other_assignment)
    return false if other_assignment == self || demand != other_assignment.demand

    valid_finish_time = [finish_time, Time.zone.now].compact.min
    valid_other_finish_time = [other_assignment.finish_time, Time.zone.now].compact.min
    assignment_contains_other(other_assignment, valid_finish_time) || other_contains_assignment(other_assignment, valid_other_finish_time)
  end

  private

  def assignment_contains_other(other_assignment, valid_finish_time)
    other_assignment.start_time.between?(start_time, valid_finish_time)
  end

  def other_contains_assignment(other_assignment, valid_other_finish_time)
    start_time.between?(other_assignment.start_time, valid_other_finish_time)
  end

  def compute_assignment_effort
    membership_flow_information = Flow::MembershipFlowInformation.new(membership)

    effort_in_assignment = membership_flow_information.compute_effort_for_assignment(self)
    stages_to_work_on = membership.stages_to_work_on
    stages_to_compute_effort = (stages_during_assignment & stages_to_work_on)

    self.assignment_for_role = stages_to_compute_effort.count.positive?
    self.item_assignment_effort = effort_in_assignment
  end

  def compute_pull_interval
    if previous_assignment.blank?
      self.pull_interval = 0
    else
      previous_assignment_finish_time = [previous_assignment.finish_time, previous_assignment.demand.end_date, Time.zone.now].compact.min
      self.pull_interval = if start_time > previous_assignment_finish_time
                             start_time - previous_assignment_finish_time
                           else
                             0
                           end
    end
  end
end
