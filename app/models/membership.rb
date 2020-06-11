# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  end_date        :date
#  hours_per_month :integer
#  member_role     :integer          default("developer"), not null
#  start_date      :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :integer          not null
#  team_member_id  :integer          not null
#
# Indexes
#
#  index_memberships_on_team_id         (team_id)
#  index_memberships_on_team_member_id  (team_member_id)
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
  scope :inactive, -> { where('memberships.end_date IS NOT NULL') }

  delegate :name, to: :team_member, prefix: true
  delegate :jira_account_id, to: :team_member
  delegate :monthly_payment, to: :team_member
  delegate :company, to: :team
  delegate :projects, to: :team_member

  def hours_per_day
    hours_per_month.to_f / 30.0
  end

  def demands_ids(item_assignments = nil)
    item_assignments = team_member.item_assignments if item_assignments.blank?

    demands_list = []
    item_assignments.each do |assignment|
      stages_during_assignment = assignment.stages_during_assignment
      demands_list << assignment.demand.id if (stages_to_work_on & stages_during_assignment).present?
    end

    demands_list
  end

  def demand_comments
    DemandComment.joins(:demand).where(demands: { team: team }).where(team_member: team_member)
  end

  def demand_blocks
    DemandBlock.joins(:demand).where(demands: { team: team }).where(blocker: team_member)
  end

  def elapsed_time
    ((end_date || Time.zone.today) - start_date).to_i
  end

  def pairing_count
    pairing_members.flatten.map(&:name).flatten.group_by(&:itself).map { |key, value| [key, value.count] }.sort_by { |_key, value| value }.reverse.to_h
  end

  def pairing_members
    return [] if team_member.demands.blank?

    pairing_members = []
    same_team_demands = team_member.demands.where(team: team)
    same_team_demands.each { |demand| pairing_members << pairing_members_in_demand(demand) }

    pairing_members.flatten
  end

  def demands
    Demand.where(id: demands_ids)
  end

  def stages_to_work_on
    stages_to_work_on = team.stages
    stages_to_work_on = team.stages.development.where(queue: false) if developer?
    stages_to_work_on
  end

  private

  def pairing_members_in_demand(demand)
    pairing_members = []

    assignments_for_member = demand.item_assignments.where(team_member: team_member)
    assignments_for_member.each do |member_assignment|
      pairing_members << demand.item_assignments
                               .joins(team_member: :memberships)
                               .where(team_member: { memberships: { member_role: member_role } })
                               .for_dates(member_assignment.start_time, member_assignment.finish_time)
                               .not_for_team_member(team_member)
                               .map(&:team_member)
    end

    pairing_members
  end

  def active_team_member_unique
    existent_memberships = Membership.where(team: team, team_member: team_member, end_date: nil)
    return if existent_memberships == [self] || end_date.present?

    errors.add(:team_member, I18n.t('activerecord.errors.models.membership.team_member.already_existent_active')) if existent_memberships.present?
  end
end
