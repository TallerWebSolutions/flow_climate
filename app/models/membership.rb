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
  enum member_role: { developer: 0, manager: 1, client: 2, designer: 3 }

  belongs_to :team
  belongs_to :team_member
  has_many :item_assignments, dependent: :destroy
  has_many :demands, through: :item_assignments
  has_many :demand_efforts, -> { distinct }, through: :item_assignments

  validates :start_date, :member_role, presence: true
  validate :active_team_member_unique

  scope :active, -> { where('memberships.end_date' => nil) }
  scope :inactive, -> { where.not('memberships.end_date' => nil) }
  scope :active_for_date, ->(limit_date) { where('start_date <= :limit_date AND (end_date IS NULL OR end_date >= :limit_date)', limit_date: limit_date.to_date) }

  delegate :name, to: :team_member, prefix: true
  delegate :jira_account_id, to: :team_member
  delegate :company, to: :team
  delegate :projects, to: :team_member

  def to_hash
    { member_name: team_member_name, jira_account_id: team_member.jira_account_id }
  end

  def member_name
    { member_name: team_member_name }
  end

  def hours_per_day
    hours_per_month.to_f / 30.0
  end

  def demands_ids
    demands_list = []
    item_assignments.includes([:demand]).find_each do |assignment|
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

  def pairing_count(date)
    pairing_members(date).flatten.map(&:team_member_name).flatten.group_by(&:itself).map { |key, value| [key, value.count] }.sort_by { |_key, value| value }.reverse.to_h
  end

  def pairing_members(date)
    return [] if demands_for_role.blank?

    pairing_members = []
    same_team_demands = demands_for_role.where(team: team).where('end_date <= :limit_date', limit_date: date.end_of_day)
    same_team_demands.each { |demand| pairing_members << pairing_members_in_demand(demand) }

    pairing_members.flatten
  end

  def demands_for_role
    Demand.where(id: demands_ids)
  end

  def stages_to_work_on
    stages_to_work_on = team.stages.where(queue: false)
    stages_to_work_on = stages_to_work_on.development if developer?
    stages_to_work_on
  end

  def monthly_payment
    return 0 if team_member.monthly_payment.blank?

    membership_share = if hours_per_month.present? && team_member.hours_per_month.present? && hours_per_month < team_member.hours_per_month
                         hours_per_month.to_f / team_member.hours_per_month
                       else
                         1
                       end

    team_member.monthly_payment * membership_share
  end

  def effort_in_period(start_date, end_date)
    demand_efforts.to_dates(start_date, end_date).sum(:effort_value)
  end

  def realized_money_in_period(start_date, end_date)
    demand_efforts.to_dates(start_date, end_date).sum(&:effort_money)
  end

  private

  def pairing_members_in_demand(demand)
    pairing_members = []

    assignments_for_member = demand.item_assignments.where(membership: self)
    assignments_for_member.each do |member_assignment|
      pairing_members << demand.item_assignments
                               .joins(:membership)
                               .where(memberships: { member_role: member_role })
                               .for_dates(member_assignment.start_time, member_assignment.finish_time)
                               .not_for_membership(self)
                               .map(&:membership)
    end

    pairing_members
  end

  def active_team_member_unique
    existent_memberships = Membership.where(team: team, team_member: team_member, end_date: nil)
    return if existent_memberships == [self] || end_date.present?

    errors.add(:team_member, I18n.t('activerecord.errors.models.membership.team_member.already_existent_active')) if existent_memberships.present?
  end
end
