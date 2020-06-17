# frozen_string_literal: true

# == Schema Information
#
# Table name: item_assignments
#
#  id                     :bigint           not null, primary key
#  assignment_for_role    :boolean          default(FALSE)
#  discarded_at           :datetime
#  finish_time            :datetime
#  item_assignment_effort :decimal(, )      default(0.0), not null
#  start_time             :datetime         not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  demand_id              :integer          not null
#  membership_id          :integer          not null
#
# Indexes
#
#  index_item_assignments_on_demand_id      (demand_id)
#  index_item_assignments_on_membership_id  (membership_id)
#
# Foreign Keys
#
#  fk_rails_0af34c141e  (demand_id => demands.id)
#  fk_rails_6ab6a3b3a4  (membership_id => memberships.id)
#

class ItemAssignment < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :membership

  validates :demand, :membership, presence: true

  validates :demand, uniqueness: { scope: %i[membership start_time], message: I18n.t('item_assignment.validations.demand_unique') }

  scope :for_dates, ->(start_date, end_date) { where('(start_time <= :end_date AND finish_time >= :start_date) OR (start_time <= :end_date AND finish_time IS NULL) OR (finish_time >= :start_date AND :end_date IS NULL) OR (start_time <= :start_date AND finish_time IS NULL)', start_date: start_date, end_date: end_date) }
  scope :not_for_membership, ->(membership) { where('item_assignments.membership_id <> :membership', membership: membership.id) }

  delegate :name, to: :membership, prefix: true

  before_save :compute_assignment_effort

  def working_hours_until(beginning_time = nil, end_time = Time.zone.now)
    start_effort_time = [start_time, beginning_time].compact.max
    end_effort_time = [finish_time, end_time].compact.min

    TimeService.instance.compute_working_hours_for_dates(start_effort_time, end_effort_time)
  end

  def stages_during_assignment
    demand.stages_at(start_time, finish_time)
  end

  private

  def compute_assignment_effort
    membership_flow_information = Flow::MembershipFlowInformation.new(membership)

    effort_in_assignment = membership_flow_information.compute_effort_for_assignment(self)
    self.assignment_for_role = effort_in_assignment.positive?
    self.item_assignment_effort = effort_in_assignment
  end
end
