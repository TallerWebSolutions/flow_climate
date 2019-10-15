# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  company_id                :integer          not null, indexed => [name]
#  created_at                :datetime         not null
#  end_date                  :date             not null
#  hour_value                :decimal(, )
#  id                        :bigint(8)        not null, primary key
#  initial_scope             :integer          not null
#  max_work_in_progress      :integer          default(0), not null
#  name                      :string           not null, indexed => [company_id]
#  nickname                  :string
#  percentage_effort_to_bugs :integer          default(0), not null
#  project_type              :integer          not null
#  qty_hours                 :decimal(, )
#  start_date                :date             not null
#  status                    :integer          not null
#  team_id                   :integer          not null
#  updated_at                :datetime         not null
#  value                     :decimal(, )
#
# Foreign Keys
#
#  fk_rails_44a549d7b3  (company_id => companies.id)
#  fk_rails_ecc227a0c2  (team_id => teams.id)
#

class Project < ApplicationRecord
  enum status: { waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4, negotiating: 5 }
  enum project_type: { outsourcing: 0, consulting: 1, training: 2, domestic_product: 3 }

  belongs_to :company
  belongs_to :team

  has_and_belongs_to_many :customers, dependent: :destroy

  has_and_belongs_to_many :products, dependent: :destroy

  has_many :jira_project_configs, class_name: 'Jira::JiraProjectConfig', dependent: :destroy, autosave: true, inverse_of: :project

  has_many :project_risk_configs, dependent: :destroy
  has_many :project_risk_alerts, dependent: :destroy
  has_many :demands, dependent: :restrict_with_error
  has_many :integration_errors, dependent: :destroy
  has_many :project_change_deadline_histories, dependent: :destroy
  has_many :stage_project_configs, dependent: :destroy
  has_many :demand_blocks, through: :demands
  has_many :stages, through: :stage_project_configs
  has_many :flow_impacts, dependent: :destroy
  has_many :project_consolidations, dependent: :destroy
  has_many :user_project_roles, dependent: :destroy
  has_many :users, through: :user_project_roles

  validates :company, :team, :qty_hours, :project_type, :name, :status, :start_date, :end_date, :status, :initial_scope, :percentage_effort_to_bugs, :max_work_in_progress, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('project.name.uniqueness') }
  validate :hour_value_project_value?

  scope :waiting_projects_starting_within_week, -> { waiting.where('EXTRACT(week FROM start_date) = :week AND EXTRACT(year FROM start_date) = :year', week: Time.zone.today.cweek, year: Time.zone.today.cwyear) }
  scope :running_projects_finishing_within_week, -> { running.where('EXTRACT(week FROM end_date) = :week AND EXTRACT(year FROM end_date) = :year', week: Time.zone.today.cweek, year: Time.zone.today.cwyear) }
  scope :running, -> { where('status = 1 OR status = 2') }
  scope :active, -> { where('status = 0 OR status = 1 OR status = 2') }
  scope :active_in_period, ->(start_period, end_period) { where('(start_date BETWEEN :start_period AND :end_period) OR (end_date BETWEEN :start_period AND :end_period)', start_period: start_period, end_period: end_period) }

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

  def remaining_money(end_period)
    hour_value_calc = hour_value || (value / qty_hours)
    (value || 0) - (consumed_hours_in_period(start_date, end_period) * hour_value_calc)
  end

  def last_week_scope
    backlog_for(1.week.ago).count + initial_scope
  end

  def backlog_unit_growth
    (backlog_for(Time.zone.now).count + initial_scope) - last_week_scope
  end

  def backlog_growth_rate
    return 0 if demands.kept.blank? || last_week_scope.zero?

    backlog_unit_growth.to_f / last_week_scope
  end

  def backlog_for(date = Time.zone.now)
    return demands.kept.count if date.blank?

    DemandsRepository.instance.known_scope_to_date(demands.map(&:id), date)
  end

  def flow_pressure(date = Time.zone.now)
    return 0.0 if no_pressure_set(date)

    days = remaining_days_to_period(date) || total_days
    remaining_backlog(date).to_f / days
  end

  def relative_flow_pressure(total_pressure)
    return 0 if total_pressure.blank? || total_pressure.zero?

    (flow_pressure / total_pressure) * 100
  end

  def total_throughput
    demands.kept.finished.count
  end

  def total_throughput_for(date = Time.zone.today)
    demands.kept.finished.where('EXTRACT(week FROM end_date) = :week AND EXTRACT(year FROM end_date) = :year', week: date.to_date.cweek, year: date.to_date.cwyear).count
  end

  def total_throughput_until(date)
    return total_throughput if date.blank?

    demands.kept.finished_until_date(date).count
  end

  def total_hours_upstream
    demands.kept.finished.sum(&:effort_upstream)
  end

  def total_hours_downstream
    demands.kept.finished.sum(&:effort_downstream)
  end

  def total_hours_consumed
    @total_hours_consumed ||= total_hours_upstream + total_hours_downstream
  end

  def required_hours_per_available_hours
    required_hours.to_f / remaining_hours
  end

  def avg_hours_per_demand
    return 0 if total_hours_consumed.zero? || total_throughput.zero?

    (total_hours_consumed.to_f / total_throughput)
  end

  def remaining_backlog(date = Time.zone.now)
    DemandsRepository.instance.remaining_backlog_to_date(demands, date.end_of_day) + initial_scope
  end

  def percentage_remaining_backlog(date = Time.zone.now)
    return 0 unless (demands.kept.count + initial_scope).positive?

    remaining_backlog(date).to_f / (demands.kept.count + initial_scope)
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
    project_risk_alerts.joins(:project_risk_config).where('project_risk_configs.risk_type = :risk_type', risk_type: ProjectRiskConfig.risk_types[risk_type]).order(created_at: :desc).first
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

  def percentage_of_demand_type(demand_type)
    return 0 if demands.kept.count.zero?

    (demands.kept.send(demand_type).count.to_f / demands.kept.count) * 100
  end

  def average_block_duration
    return 0 if demands.kept.blank? || demand_blocks.kept.blank?

    active_kept_closed_blocks.average(:block_duration)
  end

  def leadtime_for_class_of_service(class_of_service, desired_percentile = 80)
    demands_in_class_of_service = demands.kept.send(class_of_service).finished
    Stats::StatisticsService.instance.percentile(desired_percentile, demands_in_class_of_service.map(&:leadtime))
  end

  def general_leadtime(percentile = 80)
    Stats::StatisticsService.instance.percentile(percentile, demands.finished.map(&:leadtime))
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

  def odds_to_deadline
    last_project_consolidation&.odds_to_deadline_project || 0
  end

  def current_risk_to_deadline
    1 - odds_to_deadline
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

  def average_speed_per_week
    return 0 if demands.kept.count.zero? || past_weeks.zero?

    demands.kept.count / past_weeks
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

  private

  def running?
    executing? || maintenance?
  end

  def no_pressure_set(date)
    remaining_days_to_period(date).zero? || total_days.zero? || remaining_backlog(date).zero?
  end

  def hour_value_project_value?
    return true if hour_value.present? || value.present?

    errors.add(:value, I18n.t('project.validations.no_value'))
    errors.add(:hour_value, I18n.t('project.validations.no_value'))
  end

  def remaining_days_to_period(from_date = Time.zone.now)
    end_date_for_from_date = end_date.end_of_day
    last_deadline_change = project_change_deadline_histories.where('created_at <= :limit_date', limit_date: from_date.utc).order(:created_at).last
    end_date_for_from_date = last_deadline_change.new_date.end_of_day if last_deadline_change.present?

    start_date_limit = [start_date.beginning_of_day, from_date].max
    return 0 if end_date_for_from_date < start_date_limit

    ((end_date_for_from_date - start_date_limit) / 1.day) + 1
  end
end
