# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_efforts
#
#  id                         :bigint           not null, primary key
#  automatic_update           :boolean          default(TRUE), not null
#  effort_value               :decimal(, )      default(0.0), not null
#  effort_with_blocks         :decimal(, )      default(0.0)
#  finish_time_to_computation :datetime         not null
#  main_effort_in_transition  :boolean          default(FALSE), not null
#  management_percentage      :decimal(, )      default(0.0), not null
#  pairing_percentage         :decimal(, )      default(0.0), not null
#  stage_percentage           :decimal(, )      default(0.0), not null
#  start_time_to_computation  :datetime         not null
#  total_blocked              :decimal(, )      default(0.0), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  demand_id                  :integer          not null
#  demand_transition_id       :integer          not null
#  item_assignment_id         :integer          not null
#
# Indexes
#
#  idx_demand_efforts_unique                     (item_assignment_id,demand_transition_id,start_time_to_computation) UNIQUE
#  index_demand_efforts_on_demand_id             (demand_id)
#  index_demand_efforts_on_demand_transition_id  (demand_transition_id)
#  index_demand_efforts_on_item_assignment_id    (item_assignment_id)
#
# Foreign Keys
#
#  fk_rails_13a84decd9  (demand_transition_id => demand_transitions.id)
#  fk_rails_3a63adbf96  (demand_id => demands.id)
#  fk_rails_ce4f1e0c32  (item_assignment_id => item_assignments.id)
#
class DemandEffort < ApplicationRecord
  belongs_to :demand
  belongs_to :item_assignment
  belongs_to :demand_transition

  validates :item_assignment, :demand_transition, :demand, :effort_value, :start_time_to_computation, :finish_time_to_computation,
            :management_percentage, :pairing_percentage, :stage_percentage, :total_blocked, presence: true

  validates :item_assignment, uniqueness: { scope: %i[demand_transition start_time_to_computation] }

  scope :upstream_efforts, -> { joins(demand_transition: :stage).where(stages: { stage_stream: :upstream }) }
  scope :downstream_efforts, -> { joins(demand_transition: :stage).where(stages: { stage_stream: :downstream }) }

  scope :developer_efforts, -> { joins(item_assignment: :membership).where(memberships: { member_role: :developer }) }
  scope :designer_efforts, -> { joins(item_assignment: :membership).where(memberships: { member_role: :designer }) }
  scope :manager_efforts, -> { joins(item_assignment: :membership).where(memberships: { member_role: :manager }) }

  scope :for_day, ->(day) { where('start_time_to_computation BETWEEN :bottom_limit AND :upper_limit', bottom_limit: day.beginning_of_day, upper_limit: day.end_of_day) }

  def who
    item_assignment.team_member_name
  end

  def stage
    demand_transition.stage_name
  end

  def member_role
    item_assignment.membership.member_role
  end
end
