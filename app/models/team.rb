# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id                   :bigint           not null, primary key
#  max_work_in_progress :integer          default(0), not null
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  company_id           :integer          not null
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
  include DemandsAggregator

  belongs_to :company
  has_and_belongs_to_many :stages

  has_many :memberships, dependent: :destroy
  has_many :team_members, through: :memberships
  has_many :projects, dependent: :restrict_with_error
  has_many :demands, dependent: :restrict_with_error
  has_many :slack_configurations, dependent: :destroy
  has_many :team_resource_allocations, dependent: :destroy
  has_many :team_resources, through: :team_resource_allocations
  has_many :demand_blocks, -> { distinct }, through: :demands

  validates :company, :name, :max_work_in_progress, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('team.name.uniqueness') }

  delegate :count, to: :projects, prefix: true

  def active_monthly_cost_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).map(&:monthly_payment).compact.sum
  end

  def active_monthly_available_hours_for_billable_types(billable_type)
    memberships.joins(:team_member).active.where(team_members: { billable: true, billable_type: billable_type }).map(&:hours_per_month).compact.sum
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
    memberships_at_date = memberships.joins(:team_member).where('(memberships.end_date >= :start_date AND memberships.start_date <= :end_date) OR (memberships.start_date <= :end_date AND memberships.end_date IS NULL) AND team_members.billable = true', start_date: start_date, end_date: end_date)

    total_hours = 0
    full_period = (end_date - start_date).to_i + 1

    return total_hours unless full_period.positive?

    memberships_at_date.each { |membership| total_hours += compute_available_hours_to_member(membership, start_date, end_date, full_period) }

    total_hours
  end

  def larger_lead_times(number_of_weeks, number_of_records)
    if number_of_weeks <= 0
      demands.kept.finished_with_leadtime.order(leadtime: :desc).first(number_of_records)
    else
      demands.kept.finished_with_leadtime.where('end_date >= :limit_date', limit_date: number_of_weeks.weeks.ago).order(leadtime: :desc).first(number_of_records)
    end
  end

  def percentage_idle_members
    active_memberships_count = memberships.active.count
    not_finished_demands = demands.kept.not_finished

    return 0 if not_finished_demands.blank? || active_memberships_count.zero?

    assigned_count = assigned_count(not_finished_demands)

    return 0 if assigned_count.zero?

    1 - (assigned_count.to_f / active_memberships_count)
  end

  def initial_scope
    projects.active.sum(&:initial_scope)
  end

  def flow_pressure
    projects.active.includes([:demands]).sum(&:flow_pressure)
  end

  private

  def assigned_count(not_finished_demands)
    open_assignments = not_finished_demands.map { |demand| demand.item_assignments.open_assignments }.flatten

    open_assignments.map(&:membership).flatten.uniq.count
  end

  def compute_available_hours_to_member(membership, start_date, end_date, full_period)
    start_period = [start_date, membership.start_date].compact.max
    end_period = [end_date, membership.end_date].compact.min

    member_period = (end_period - start_period).to_i + 1

    participation_ratio = member_period.to_f / full_period

    (membership.hours_per_day.to_f * full_period) * participation_ratio
  end
end
