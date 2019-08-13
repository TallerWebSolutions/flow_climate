# frozen_string_literal: true

# == Schema Information
#
# Table name: item_assignments
#
#  created_at     :datetime         not null
#  demand_id      :integer          not null, indexed => [team_member_id, start_time], indexed
#  finish_time    :datetime
#  id             :bigint(8)        not null, primary key
#  start_time     :datetime         not null, indexed => [demand_id, team_member_id]
#  team_member_id :integer          not null, indexed => [demand_id, start_time], indexed
#  updated_at     :datetime         not null
#
# Indexes
#
#  demand_member_start_time_unique           (demand_id,team_member_id,start_time) UNIQUE
#  index_item_assignments_on_demand_id       (demand_id)
#  index_item_assignments_on_team_member_id  (team_member_id)
#
# Foreign Keys
#
#  fk_rails_0af34c141e  (demand_id => demands.id)
#  fk_rails_78b4938f25  (team_member_id => team_members.id)
#

class ItemAssignment < ApplicationRecord
  belongs_to :demand
  belongs_to :team_member

  validates :demand, :team_member, presence: true

  validates :demand, uniqueness: { scope: %i[team_member start_time], message: I18n.t('item_assignment.validations.demand_unique') }

  def working_hours
    end_time = finish_time || Time.zone.now

    TimeService.instance.compute_working_hours_for_dates(start_time, end_time)
  end
end
