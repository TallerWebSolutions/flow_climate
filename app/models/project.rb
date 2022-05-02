# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                        :bigint           not null, primary key
#  end_date                  :date             not null
#  hour_value                :decimal(, )
#  initial_scope             :integer          not null
#  max_work_in_progress      :decimal(, )      default(1.0), not null
#  name                      :string           not null
#  nickname                  :string
#  percentage_effort_to_bugs :integer          default(0), not null
#  project_type              :integer          not null
#  qty_hours                 :decimal(, )
#  start_date                :date             not null
#  status                    :integer          not null
#  value                     :decimal(, )
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_id                :integer          not null
#  initiative_id             :integer
#  team_id                   :integer          not null
#
# Indexes
#
#  index_projects_on_company_id_and_name  (company_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_44a549d7b3  (company_id => companies.id)
#  fk_rails_ecc227a0c2  (team_id => teams.id)
#  fk_rails_f78e8f0103  (initiative_id => initiatives.id)
#

class Project < ApplicationRecord
  paginates_per 10

  include DemandsAggregator

  enum status: { waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4, negotiating: 5 }
  enum project_type: { outsourcing: 0, consulting: 1, training: 2, domestic_product: 3, marketing: 4 }

  belongs_to :company
  belongs_to :team
  belongs_to :initiative, optional: true

  has_many :customers_projects, dependent: :destroy
  has_many :customers, through: :customers_projects, dependent: :destroy

  has_many :products_projects, dependent: :destroy
  has_many :products, through: :products_projects, dependent: :destroy

  has_many :jira_project_configs, class_name: 'Jira::JiraProjectConfig', dependent: :destroy, autosave: true, inverse_of: :project

  has_many :project_risk_configs, dependent: :destroy
  has_many :project_risk_alerts, dependent: :destroy
  has_many :demands, dependent: :restrict_with_error
  has_many :tasks, through: :demands
  has_many :demand_blocks, through: :demands
  has_many :demand_efforts, through: :demands
  has_many :memberships, -> { distinct }, through: :demands
  has_many :team_members, -> { distinct }, through: :memberships
  has_many :project_change_deadline_histories, dependent: :destroy
  has_many :stage_project_configs, dependent: :destroy
  has_many :stages, through: :stage_project_configs
  has_many :flow_events, dependent: :destroy
  has_many :project_consolidations, dependent: :destroy, class_name: 'Consolidations::ProjectConsolidation'
  has_many :replenishing_consolidations, dependent: :destroy, class_name: 'Consolidations::ReplenishingConsolidation'
  has_many :user_project_roles, dependent: :destroy
  has_many :users, through: :user_project_roles
  has_many :project_broken_wip_logs, dependent: :destroy

  validates :qty_hours, :project_type, :name, :status, :start_date, :end_date, :status, :initial_scope, :percentage_effort_to_bugs, :max_work_in_progress, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('project.name.uniqueness') }
  validate :hour_value_project_value?

  scope :waiting_projects_starting_within_week, -> { waiting.where('EXTRACT(week FROM projects.start_date) = :week AND EXTRACT(year FROM projects.start_date) = :year', week: Time.zone.today.cweek, year: Time.zone.today.cwyear) }
  scope :running_projects_finishing_within_week, -> { running.where('EXTRACT(week FROM projects.end_date) = :week AND EXTRACT(year FROM projects.end_date) = :year', week: Time.zone.today.cweek, year: Time.zone.today.cwyear) }
  scope :running, -> { where('(projects.status = 1 OR projects.status = 2) AND projects.start_date <= :limit_date', limit_date: Time.zone.today) }
  scope :active, -> { where('(projects.status = 0 OR projects.status = 1 OR  projects.status = 2) AND projects.end_date >= :limit_date', limit_date: Time.zone.today) }
  scope :active_in_period, ->(start_period, end_period) { where('(projects.start_date BETWEEN :start_period AND :end_period) OR (projects.end_date BETWEEN :start_period AND :end_period)', start_period: start_period, end_period: end_period) }
  scope :finishing_after, ->(date) { where('projects.end_date >= :end_date', end_date: date) }
  scope :not_cancelled, -> { where.not(status: :cancelled) }

  after_save :remove_outdated_consolidations
  after_save :update_initiative_dates

  def to_hash
    { id: id, name: name, start_date: start_date, end_date: end_date, remaining_backlog: remaining_backlog,
      remaining_days: remaining_days, remaining_weeks: remaining_weeks, remaining_hours: remaining_hours,
      produced_hours_in_current_month: project_consolidations.order(:consolidation_date).last&.project_throughput_hours_in_month&.to_f || 0,
      produced_hours_total: consumed_hours,
      deadline_risk: current_risk_to_deadline.to_f,
      deadline_risk_team_info: (last_project_consolidation&.team_based_operational_risk || 1), current_lead_time: last_project_consolidation&.lead_time_p80 }
  end

  def add_user(user)
    return if users.include?(user)

    users << user
  end

  def add_customer(customer)
    return if customers.include?(customer)

    customers << customer
    save
  end

  def remove_customer(customer)
    customers.delete(customer) if customers.include?(customer)
    save
  end

  def add_product(product)
    return if products.include?(product)

    products << product
    save
  end

  def remove_product(product)
    products.delete(product) if products.include?(product)
    save
  end

  def red?
    project_risk_configs.each do |risk_config|
      risk_alert = project_risk_alerts.where(project_risk_config: risk_config).order(:created_at).last
      return true if risk_alert&.red?
    end

    false
  end

  def total_days
    ((end_date.end_of_day - start_date.beginning_of_day) / 1.day) + 1
  end

  def total_weeks
    ((end_date.end_of_day - start_date.beginning_of_day) / 1.week) + 1
  end

  def past_weeks
    return total_weeks if finished?
    return 0 unless running?

    ((Time.zone.today.end_of_day - start_date.beginning_of_day) / 1.week) + 1
  end

  def remaining_weeks(from_date = Time.zone.today)
    start_date_limit = [start_date, from_date].max
    return 0 if end_date < start_date_limit

    ((start_date_limit.end_of_week.upto(end_date.to_date.end_of_week).count.to_f + 1) / 7).round + 1
  end

  def remaining_days(from_date = Time.zone.now)
    start_date_limit = [start_date.beginning_of_day, from_date].max
    return 0 if end_date.end_of_day < start_date_limit

    (((end_date.end_of_day - start_date_limit.beginning_of_day) / 1.day)).round
  end

  def percentage_remaining_days
    return 0 if total_days.zero?

    ((remaining_days.to_f / total_days) * 100).round(2)
  end

  def consumed_hours_in_period(start_date, end_date)
    demands.kept.to_end_dates(start_date, end_date).sum(&:total_effort)
  end

  def remaining_money(end_period = Time.zone.today.end_of_day)
    hour_value_calc = hour_value || (value / qty_hours)
    (value || 0) - (consumed_hours_in_period(start_date, end_period) * hour_value_calc)
  end

  def consumed_hours
    last_consolidation = project_consolidations.order(:consolidation_date).last
    return last_consolidation.project_throughput_hours if last_consolidation.present?

    demands.kept.finished_until_date(Time.zone.now).sum(&:total_effort)
  end

  def last_week_scope
    backlog_for(1.week.ago).count + initial_scope
  end

  def backlog_unit_growth
    backlog_count_for - last_week_scope
  end

  def backlog_growth_rate
    return 0 if demands.kept.blank? || last_week_scope.zero?

    backlog_unit_growth.to_f / last_week_scope
  end

  def flow_pressure(date = Time.zone.now)
    return 0 if no_pressure_set(date)

    days = remaining_days_to_period(date) || total_days
    remaining_work(date).to_f / days
  end

  def relative_flow_pressure(total_pressure)
    return 0 if total_pressure.blank? || total_pressure.zero?

    (flow_pressure / total_pressure) * 100
  end

  def relative_flow_pressure_in_replenishing_consolidation(date = Time.zone.today)
    replenishing_consolidations.where(consolidation_date: date).order(:consolidation_date).last&.relative_flow_pressure || 0
  end

  def total_throughput
    demands.kept.finished_until_date(Time.zone.now).count
  end

  def total_throughput_for(date = Time.zone.today)
    demands.kept.finished_until_date(Time.zone.now).where('EXTRACT(week FROM end_date) = :week AND EXTRACT(year FROM end_date) = :year', week: date.to_date.cweek, year: date.to_date.cwyear).count
  end

  def total_throughput_until(date)
    return total_throughput if date.blank?

    demands.not_discarded_until(date).finished_until_date(date).count
  end

  def total_hours_upstream
    demands.kept.finished_until_date(Time.zone.now).sum(&:effort_upstream)
  end

  def total_hours_downstream
    demands.kept.finished_until_date(Time.zone.now).sum(&:effort_downstream)
  end

  def total_hours_consumed
    total_hours_upstream + total_hours_downstream
  end

  def required_hours_per_available_hours
    required_hours.to_f / remaining_hours
  end

  def avg_hours_per_demand
    return 0 if total_hours_consumed.zero? || total_throughput.zero?

    (total_hours_consumed.to_f / total_throughput)
  end

  def remaining_backlog(date = Time.zone.now)
    demands.not_discarded_until(date.end_of_day).not_started(date.end_of_day).count + initial_scope
  end

  def remaining_work(date = Time.zone.now)
    demands.opened_before_date(date).not_discarded_until(date).not_finished(date).count + initial_scope
  end

  def percentage_remaining_work(date = Time.zone.now)
    total_demands_count = demands.opened_before_date(date.end_of_day).count + initial_scope
    return 0 unless total_demands_count.positive?

    remaining_work(date.end_of_day) / total_demands_count.to_f
  end

  def required_hours
    remaining_backlog * avg_hours_per_demand
  end

  def remaining_hours
    qty_hours - total_hours_consumed
  end

  def risk_color
    return 'green' if project_risk_alerts.empty?

    project_risk_alerts.order(:created_at).last.alert_color
  end

  def money_per_deadline
    remaining_money(end_date).to_f / remaining_days
  end

  def backlog_growth_throughput_rate
    return backlog_unit_growth if total_throughput_for(Time.zone.today).zero?

    backlog_unit_growth.to_f / total_throughput_for(Time.zone.today)
  end

  def last_alert_for(risk_type)
    project_risk_alerts.joins(:project_risk_config).where('project_risk_configs.risk_type' => ProjectRiskConfig.risk_types[risk_type]).order(created_at: :desc).first
  end

  def hours_per_month
    hours_per_day * 30
  end

  def hours_per_day
    qty_hours.to_f / total_days
  end

  def money_per_month
    money_per_day * 30
  end

  def money_per_day
    value / total_days.to_f
  end

  def current_cost
    @current_cost ||= total_hours_consumed * hour_value
  end

  def average_speed
    DemandService.instance.average_speed(demands.kept.finished_until_date(Time.zone.now))
  end

  def percentage_of_demand_type(demand_type)
    return 0 if demands.kept.count.zero?

    (demands.kept.send(demand_type).count.to_f / demands.kept.count) * 100
  end

  def average_block_duration
    return 0 if demands.kept.blank? || demand_blocks.kept.blank?

    active_kept_closed_blocks.average(:block_working_time_duration)
  end

  def leadtime_for_class_of_service(class_of_service, desired_percentile = 80)
    demands_in_class_of_service = demands.send(class_of_service).finished_until_date(Time.zone.now)
    Stats::StatisticsService.instance.percentile(desired_percentile, demands_in_class_of_service.map(&:leadtime))
  end

  def general_leadtime(percentile = 80)
    Stats::StatisticsService.instance.percentile(percentile, demands.finished_until_date(Time.zone.now).map(&:leadtime))
  end

  def active_kept_closed_blocks
    demand_blocks.kept.active.closed
  end

  def percentage_expedite
    return 0 if demands.kept.count.zero?

    (demands_of_class_of_service(:expedite).count.to_f / demands.kept.count) * 100
  end

  def percentage_standard
    return 0 if demands.kept.count.zero?

    (demands.kept.standard.count.to_f / demands.kept.count) * 100
  end

  def percentage_fixed_date
    return 0 if demands.kept.count.zero?

    (demands.kept.fixed_date.count.to_f / demands.kept.count) * 100
  end

  def percentage_intangible
    return 0 if demands.kept.count.zero?

    (demands.kept.intangible.count.to_f / demands.kept.count) * 100
  end

  def aging
    (end_date - start_date).to_i
  end

  def aging_today
    (Time.zone.today - start_date).to_i
  end

  def current_risk_to_deadline
    return 1 if last_project_consolidation.blank?

    last_project_consolidation.operational_risk
  end

  def tasks_based_current_risk_to_deadline
    return 1 if last_project_consolidation.blank?

    last_project_consolidation.tasks_based_operational_risk
  end

  def consolidations_last_update
    last_project_consolidation&.updated_at
  end

  def last_project_consolidation
    project_consolidations.order(:consolidation_date).last
  end

  def failure_load
    total_demands = demands.kept
    Stats::StatisticsService.instance.compute_percentage(total_demands.bug.count, (total_demands.count - total_demands.bug.count))
  end

  def demands_of_class_of_service(class_of_service = :standard)
    demands.kept.send(class_of_service)
  end

  def first_deadline
    return end_date if project_change_deadline_histories.blank?

    project_change_deadline_histories.order(:previous_date).first.previous_date
  end

  def days_difference_between_first_and_last_deadlines
    (end_date - first_deadline).to_i
  end

  def average_demand_aging
    return 0 if demands.kept.blank?

    demands.kept.sum(&:aging_when_finished) / demands.kept.count
  end

  def quality(limit_date = Time.zone.today)
    demands_in = demands.not_discarded_until(limit_date.end_of_day).until_date(limit_date.end_of_day)

    return 0 if demands_in.count.zero?
    return 1 if demands_in.bug.count.zero?

    1 - (demands_in.kept.bug.count.to_f / demands_in.kept.count)
  end

  def value_per_demand
    return value if delivered_scope.zero? || delivered_scope == 1

    value.to_f / delivered_scope
  end

  def delivered_scope
    @delivered_scope ||= demands.finished_until_date(Time.zone.now).count
  end

  def last_weekly_throughput(qty_data_points = nil)
    qty_data_points = project_consolidations.count if qty_data_points.blank?
    consolidations = project_consolidations.weekly_data.order(consolidation_date: :desc)
    consolidations = project_consolidations.order(consolidation_date: :desc) if consolidations.empty?

    throughputs = consolidations.first(qty_data_points).map(&:project_throughput).flatten

    previous_element = -1
    last_throughputs = []
    throughputs.each do |th|
      last_throughputs << (previous_element - th) unless previous_element == -1

      previous_element = th
    end

    last_throughputs.reverse
  end

  def current_weekly_scope_ideal_burnup
    period = TimeService.instance.weeks_between_of(start_date, end_date)
    ideal_per_period = []
    scope_base = project_consolidations.present? ? project_consolidations.order(:consolidation_date).last.project_scope : backlog_count_for

    period.each_with_index { |_date, index| ideal_per_period << ((scope_base.to_f / period.size) * (index + 1)) }

    ideal_per_period
  end

  def current_weekly_hours_ideal_burnup
    period = TimeService.instance.weeks_between_of(start_date, end_date)
    ideal_per_period = []
    period.each_with_index { |_date, index| ideal_per_period << ((qty_hours.to_f / period.size) * (index + 1)) }
    ideal_per_period
  end

  def weekly_project_scope_until_end
    return [backlog_count_for] if project_consolidations.blank?

    period = TimeService.instance.weeks_between_of(start_date, end_date)
    project_scopes = project_consolidations.weekly_data.order(:consolidation_date).map(&:project_scope)

    last_scope = project_consolidations.order(:consolidation_date).last.project_scope
    scope_to_fill = period.count - project_scopes.count

    project_scopes + Array.new(scope_to_fill, last_scope)
  end

  def weekly_project_scope_hours_until_end
    return [qty_hours] if project_consolidations.blank?

    period = TimeService.instance.weeks_between_of(start_date, end_date)
    project_scope_hours = project_consolidations.weekly_data.order(:consolidation_date).map(&:project_scope_hours)

    last_scope = project_consolidations.order(:consolidation_date).last.project_scope_hours
    scope_to_fill = period.count - project_scope_hours.count

    project_scope_hours + Array.new(scope_to_fill, last_scope)
  end

  def backlog_count_for(date = Time.zone.now.end_of_day)
    backlog_for(date).count + initial_scope
  end

  def remove_outdated_consolidations
    project_consolidations.where('consolidation_date < :limit_date', limit_date: start_date).map(&:destroy)
    project_consolidations.where('consolidation_date > :limit_date', limit_date: end_date).map(&:destroy)
  end

  def qty_selected_in_week(date = Time.zone.today)
    DemandsRepository.instance.committed_demands_to_period(demands.kept, date.to_date.cweek, date.to_date.cwyear).count
  end

  def monte_carlo_p80(date = Time.zone.today)
    replenishing_consolidations_to_date(date)&.montecarlo_80_percent || 0
  end

  def team_monte_carlo_p80(date = Time.zone.today)
    replenishing_consolidations_to_date(date)&.team_based_montecarlo_80_percent || 0
  end

  def team_monte_carlo_weeks_max(date = Time.zone.today)
    replenishing_consolidations_to_date(date)&.team_monte_carlo_weeks_max || 0
  end

  def team_monte_carlo_weeks_min(date = Time.zone.today)
    replenishing_consolidations_to_date(date)&.team_monte_carlo_weeks_min || 0
  end

  def team_monte_carlo_weeks_std_dev(date = Time.zone.today)
    replenishing_consolidations_to_date(date)&.team_monte_carlo_weeks_std_dev || 0
  end

  def team_based_odds_to_deadline(date = Time.zone.today)
    replenishing_consolidations_to_date(date)&.team_based_odds_to_deadline || 0
  end

  def in_wip(date = Time.zone.today)
    demands.kept.in_wip(date)
  end

  def running?
    executing? || maintenance?
  end

  private

  def replenishing_consolidations_to_date(date)
    ordered_consolidations = replenishing_consolidations.order(:consolidation_date)
    (ordered_consolidations.where(consolidation_date: date).last || ordered_consolidations.last)
  end

  def backlog_for(date = Time.zone.now)
    DemandsRepository.instance.known_scope_to_date(demands.map(&:id), date)
  end

  def no_pressure_set(date)
    remaining_days_to_period(date).zero? || total_days.zero? || remaining_backlog(date).zero?
  end

  def hour_value_project_value?
    return true if hour_value.present? || value.present?

    errors.add(:value, I18n.t('project.validations.no_value'))
    errors.add(:hour_value, I18n.t('project.validations.no_value'))
  end

  def remaining_days_to_period(from_date = Time.zone.today)
    end_date_for_from_date = end_date
    last_deadline_change = project_change_deadline_histories.where('created_at <= :limit_date', limit_date: from_date.utc).order(:created_at).last
    end_date_for_from_date = last_deadline_change.new_date if last_deadline_change.present?

    start_date_limit = [start_date, from_date.to_date].max
    return 0 if end_date_for_from_date < start_date_limit

    (end_date_for_from_date - start_date_limit) + 1
  end

  def update_initiative_dates
    return if initiative.blank?

    initiative_reloaded = initiative.reload
    start_date = initiative_reloaded.projects.map(&:start_date).min
    end_date = initiative_reloaded.projects.map(&:end_date).max

    initiative_reloaded.update(start_date: start_date, end_date: end_date)
  end
end
