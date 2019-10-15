# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  created_at      :datetime         not null
#  end_date        :date
#  hours_per_month :integer
#  id              :bigint(8)        not null, primary key
#  member_role     :integer          default("developer"), not null
#  start_date      :date             not null
#  team_id         :integer          not null, indexed
#  team_member_id  :integer          not null, indexed
#  updated_at      :datetime         not null
#
# Foreign Keys
#
#  fk_rails_1138510838  (team_member_id => team_members.id)
#  fk_rails_ae2aedcfaf  (team_id => teams.id)
#

class Membership < ApplicationRecord
  enum member_role: { developer: 0, manager: 1, client: 2 }

  belongs_to :team
  belongs_to :team_member

  validates :team, :team_member, :start_date, presence: true
  validate :active_team_member_unique

  scope :active, -> { where('memberships.end_date IS NULL') }

  delegate :name, to: :team_member, prefix: true
  delegate :jira_account_id, to: :team_member
  delegate :monthly_payment, to: :team_member

  def hours_per_day
    hours_per_month.to_f / 30.0
  end

  def demands
    Demand.joins(:item_assignments).where(demands: { team: team }).where(item_assignments: { team_member: team_member })
  end

  def demand_comments
    DemandComment.joins(:demand).where(demands: { team: team }).where(team_member: team_member)
  end

  def demand_blocks
    DemandBlock.joins(:demand).where(demands: { team: team }).where(blocker: team_member)
  end

  def leadtime(percentile = 80)
    Stats::StatisticsService.instance.percentile(percentile, demands.finished_with_leadtime.map(&:leadtime))
  end

  def elapsed_time
    ((end_date || Time.zone.today) - start_date).to_i
  end

  def pairing_count
    pairing_members.group_by(&:itself).map { |key, value| [key, value.count] }.sort_by { |_key, value| value }.reverse.to_h
  end

  def pairing_members
    demands_member_in = team_member.demands.where(team: team)
    @pairing_members = demands_member_in.map { |demand| demand.team_members.joins(:memberships).where(memberships: { member_role: member_role }).map(&:name) }.flatten - [team_member.name]
  end

  private

  def active_team_member_unique
    existent_memberships = Membership.where(team: team, team_member: team_member, end_date: nil)
    return if existent_memberships == [self]

    errors.add(:team_member, I18n.t('activerecord.errors.models.membership.team_member.already_existent_active')) if existent_memberships.present?
  end
end
