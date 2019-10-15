# frozen_string_literal: true

# == Schema Information
#
# Table name: item_assignments
#
#  created_at     :datetime         not null
#  demand_id      :integer          not null, indexed => [team_member_id, start_time], indexed
#  discarded_at   :datetime
#  finish_time    :datetime
#  id             :bigint(8)        not null, primary key
#  start_time     :datetime         not null, indexed => [demand_id, team_member_id]
#  team_member_id :integer          not null, indexed => [demand_id, start_time], indexed
#  updated_at     :datetime         not null
#
# Foreign Keys
#
#  fk_rails_0af34c141e  (demand_id => demands.id)
#  fk_rails_78b4938f25  (team_member_id => team_members.id)
#

class ItemAssignment < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :team_member

  validates :demand, :team_member, presence: true

  validates :demand, uniqueness: { scope: %i[team_member start_time], message: I18n.t('item_assignment.validations.demand_unique') }

  scope :for_dates, ->(start_date, end_date) { where('(start_time <= :end_date) AND (finish_time IS NULL OR finish_time >= :start_date)', start_date: start_date, end_date: end_date) }

  delegate :name, to: :team_member, prefix: true

  def working_hours_until(beginning_time = nil, end_time = Time.zone.now)
    start_effort_time = [start_time, beginning_time].compact.max
    end_effort_time = [finish_time, end_time].compact.min

    TimeService.instance.compute_working_hours_for_dates(start_effort_time, end_effort_time)
  end
end
