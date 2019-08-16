# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  company_id           :integer          not null, indexed, indexed => [name]
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  max_work_in_progress :integer          default(0), not null
#  name                 :string           not null, indexed => [company_id]
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_teams_on_company_id           (company_id)
#  index_teams_on_company_id_and_name  (company_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_e080df8a94  (company_id => companies.id)
#

class Team < ApplicationRecord
  include ProjectAggregator

  belongs_to :company
  has_and_belongs_to_many :stages

  has_many :memberships, dependent: :destroy
  has_many :team_members, through: :memberships
  has_many :projects, dependent: :restrict_with_error
  has_many :demands, dependent: :restrict_with_error
  has_many :slack_configurations, dependent: :destroy

  validates :company, :name, :max_work_in_progress, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('team.name.uniqueness') }

  delegate :count, to: :projects, prefix: true

  def active_monthly_cost_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).map(&:monthly_payment).compact.sum
  end

  def active_monthly_available_hours_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).map(&:hours_per_month).compact.sum
  end

  def consumed_hours_in_month(required_date)
    demands.kept.where('EXTRACT(YEAR from demands.end_date) = :year AND EXTRACT(MONTH from demands.end_date) = :month', year: required_date.to_date.cwyear, month: required_date.to_date.month).sum(&:total_effort)
  end

  def lead_time(start_date, end_date, percentile = 80)
    Stats::StatisticsService.instance.percentile(percentile, demands.finished.where('demands.end_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date).map(&:leadtime))
  end

  def failure_load
    total_demands = demands.kept
    Stats::StatisticsService.instance.compute_percentage(total_demands.bug.count, (total_demands.count - total_demands.bug.count))
  end

  def available_hours_at(start_date, end_date)
    team_members_at_date = team_members.where('(end_date >= :start_date AND start_date <= :end_date) OR (start_date <= :end_date AND end_date IS NULL) AND billable = true', start_date: start_date, end_date: end_date)

    total_hours = 0
    full_period = (end_date - start_date).to_i + 1

    return total_hours unless full_period.positive?

    team_members_at_date.each do |member|
      total_hours += compute_available_hours_to_member(end_date, full_period, member, start_date)
    end

    total_hours
  end

  private

  def compute_available_hours_to_member(end_date, full_period, member, start_date)
    start_period = [start_date, member.start_date].compact.max
    end_period = [end_date, member.end_date].compact.min

    member_period = (end_period - start_period).to_i + 1

    participation_ratio = member_period.to_f / full_period

    (member.hours_per_day.to_f * full_period) * participation_ratio
  end
end
