# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  created_at                :datetime         not null
#  customer_id               :integer          not null, indexed, indexed => [nickname]
#  end_date                  :date             not null
#  hour_value                :decimal(, )
#  id                        :bigint(8)        not null, primary key
#  initial_scope             :integer          not null
#  name                      :string           not null, indexed => [product_id]
#  nickname                  :string           indexed => [customer_id]
#  percentage_effort_to_bugs :integer          default(0), not null
#  product_id                :integer          indexed => [name]
#  project_type              :integer          not null
#  qty_hours                 :decimal(, )
#  start_date                :date             not null
#  status                    :integer          not null
#  team_id                   :integer
#  updated_at                :datetime         not null
#  value                     :decimal(, )
#
# Indexes
#
#  index_projects_on_customer_id               (customer_id)
#  index_projects_on_nickname_and_customer_id  (nickname,customer_id) UNIQUE
#  index_projects_on_product_id_and_name       (product_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_21e11c2480  (product_id => products.id)
#  fk_rails_47c768ed16  (customer_id => customers.id)
#  fk_rails_ecc227a0c2  (team_id => teams.id)
#

class Project < ApplicationRecord
  enum status: { waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4, negotiating: 5 }
  enum project_type: { outsourcing: 0, consulting: 1, training: 2, domestic_product: 3 }

  belongs_to :customer, counter_cache: true
  belongs_to :product, counter_cache: true
  belongs_to :team

  has_many :project_results, dependent: :destroy
  has_many :project_risk_configs, dependent: :destroy
  has_many :project_risk_alerts, dependent: :destroy
  has_many :demands, dependent: :destroy
  has_many :demand_blocks, through: :demands
  has_many :integration_errors, dependent: :destroy
  has_many :project_change_deadline_histories, dependent: :destroy
  has_many :stage_project_configs, dependent: :destroy
  has_many :stages, through: :stage_project_configs
  has_one :pipefy_config, class_name: 'Pipefy::PipefyConfig', dependent: :destroy, autosave: true, inverse_of: :project
  has_one :project_jira_config, class_name: 'Jira::ProjectJiraConfig', dependent: :destroy, autosave: true, inverse_of: :project

  validates :customer, :qty_hours, :project_type, :name, :status, :start_date, :end_date, :status, :initial_scope, :percentage_effort_to_bugs, presence: true
  validates :name, uniqueness: { scope: :product, message: I18n.t('project.name.uniqueness') }
  validates :nickname, uniqueness: { scope: :customer, message: I18n.t('project.nickname.uniqueness') }, allow_nil: true
  validate :hour_value_project_value?, :product_required?

  delegate :name, to: :customer, prefix: true
  delegate :name, to: :product, prefix: true, allow_nil: true
  delegate :company, to: :customer

  scope :waiting_projects_starting_within_week, -> { waiting.where('EXTRACT(week FROM start_date) = :week AND EXTRACT(year FROM start_date) = :year', week: Time.zone.today.cweek, year: Time.zone.today.cwyear) }
  scope :running_projects_finishing_within_week, -> { running.where('EXTRACT(week FROM end_date) = :week AND EXTRACT(year FROM end_date) = :year', week: Time.zone.today.cweek, year: Time.zone.today.cwyear) }
  scope :running, -> { where('status = 1 OR status = 2') }
  scope :active, -> { where('status = 0 OR status = 1 OR status = 2') }
  scope :no_pipefy_config, -> { left_outer_joins(:pipefy_config).where('pipefy_configs.id IS NULL') }

  def red?
    project_risk_configs.each do |risk_config|
      risk_alert = project_risk_alerts.where(project_risk_config: risk_config).order(:created_at).last
      return true if risk_alert&.red?
    end

    false
  end

  def full_name
    return name if customer.blank?
    return "#{customer_name} | #{product_name} | #{name}" if product.present?

    "#{customer_name} | #{name}"
  end

  def total_days
    (end_date - start_date).to_i + 1
  end

  def remaining_days(from_date = Time.zone.today)
    return 0 if end_date < from_date || end_date < start_date
    return (end_date - start_date).to_i + 1 if start_date > from_date.to_date

    (end_date - from_date.to_date).to_i + 1
  end

  def percentage_remaining_days
    return 0 if total_days.zero?

    (remaining_days.to_f / total_days.to_f) * 100
  end

  def consumed_hours
    project_results.sum(&:project_delivered_hours)
  end

  def remaining_money
    hour_value_calc = hour_value || (value / qty_hours)
    value - (consumed_hours * hour_value_calc)
  end

  def percentage_remaining_money
    return 0 if value.zero?

    (remaining_money / value) * 100
  end

  def penultimate_week_scope
    locate_last_results_for_date.first&.known_scope || initial_scope
  end

  def last_week_scope
    locate_last_results_for_date.last&.known_scope || initial_scope
  end

  def backlog_unit_growth
    last_week_scope - penultimate_week_scope
  end

  def backlog_growth_rate
    return 0 if locate_last_results_for_date.first.blank? || locate_last_results_for_date.first.known_scope.zero?

    backlog_unit_growth.to_f / locate_last_results_for_date.first.known_scope.to_f
  end

  def backlog_for(date = Time.zone.today)
    return initial_scope if date.blank?

    project_results.for_week(date.to_date.cweek, date.to_date.cwyear).last&.known_scope || initial_scope
  end

  def current_team
    team || project_results.order(result_date: :desc)&.first&.team || product&.team || project_jira_config&.team
  end

  def update_team_in_product(team)
    product.update(team: team) if product.present?
  end

  def flow_pressure(date = Time.zone.today)
    return 0.0 if no_pressure_set(date)

    days = remaining_days(date) || total_days
    backlog_remaining(date).to_f / days.to_f
  end

  def total_throughput
    project_results.sum(&:throughput_downstream) + project_results.sum(&:throughput_upstream)
  end

  def total_throughput_upstream
    project_results.sum(&:throughput_upstream)
  end

  def total_throughput_downstream
    project_results.sum(&:throughput_downstream)
  end

  def total_throughput_for(date = Time.zone.today)
    project_results.for_week(date.to_date.cweek, date.to_date.cwyear).sum(:throughput_downstream) + project_results.for_week(date.to_date.cweek, date.to_date.cwyear).sum(:throughput_upstream)
  end

  def total_throughput_until(date)
    return total_throughput if date.blank?

    demands.kept.finished_until_date(date).count
  end

  def total_hours_upstream
    project_results.sum(&:qty_hours_upstream)
  end

  def total_hours_downstream
    project_results.sum(&:qty_hours_downstream)
  end

  def total_hours_consumed
    project_results.sum(&:project_delivered_hours)
  end

  def required_hours_per_available_hours
    required_hours.to_f / remaining_hours.to_f
  end

  def total_bugs_opened
    demands.kept.bug.not_finished.count
  end

  def total_bugs_closed
    demands.kept.bug.finished.count
  end

  def total_hours_bug
    project_results.sum(&:qty_hours_bug)
  end

  def avg_leadtime
    project_results&.order(:result_date)&.last&.leadtime_average || 0
  end

  def avg_hours_per_demand
    return 0 if project_results.empty? || total_hours_consumed.zero? || total_throughput.zero?

    (total_hours_consumed.to_f / total_throughput.to_f)
  end

  def avg_hours_per_demand_upstream
    return 0 if project_results.empty? || total_hours_upstream.zero? || total_throughput.zero?

    (total_hours_upstream.to_f / total_throughput_upstream.to_f)
  end

  def avg_hours_per_demand_downstream
    return 0 if project_results.empty? || total_hours_downstream.zero? || total_throughput_downstream.zero?

    (total_hours_downstream.to_f / total_throughput_downstream.to_f)
  end

  def backlog_remaining(date = Time.zone.today)
    known_scope = DemandsRepository.instance.known_scope_to_date(self, date) + initial_scope
    known_scope - total_throughput_until(date)
  end

  def required_hours
    backlog_remaining * regressive_hours_per_demand
  end

  def remaining_hours
    qty_hours - total_hours_consumed
  end

  def risk_color
    return 'green' if project_risk_alerts.empty?

    project_risk_alerts.order(:created_at).last.alert_color
  end

  def money_per_deadline
    percentage_remaining_days / percentage_remaining_money
  end

  def backlog_growth_throughput_rate
    return backlog_unit_growth if total_throughput_for(Time.zone.today).to_f.zero?

    backlog_unit_growth.to_f / total_throughput_for(Time.zone.today).to_f
  end

  def last_alert_for(risk_type)
    project_risk_alerts.joins(:project_risk_config).where('project_risk_configs.risk_type = :risk_type', risk_type: ProjectRiskConfig.risk_types[risk_type]).order(created_at: :desc).first
  end

  def average_demand_cost
    return 0 if project_results.blank?
    return current_cost if total_throughput.zero? || total_throughput == 1

    current_cost / total_throughput
  end

  def hours_per_month
    qty_hours.to_f / (total_days.to_f / 30)
  end

  def money_per_month
    value / (total_days.to_f / 30)
  end

  def manual?
    pipefy_config.blank?
  end

  def current_cost
    return 0 if project_results.blank?

    project_results.order(:result_date).last.cost_in_month
  end

  def percentage_of_demand_type(demand_type)
    return 0 if demands.kept.count.zero?

    (demands.kept.send(demand_type).count.to_f / demands.kept.count.to_f) * 100
  end

  def average_block_duration
    return 0 if demands.kept.blank? || demand_blocks.kept.blank?

    active_and_kept_blocks.average(:block_duration)
  end

  def leadtime_for_class_of_service(class_of_service, desired_percentile = 80)
    demands_in_class_of_service = demands.kept.send(class_of_service).finished
    Stats::StatisticsService.instance.percentile(desired_percentile, demands_in_class_of_service.map(&:leadtime))
  end

  def leadtime_for_demand_type(demand_type, desired_percentile = 80)
    demands_in_type = demands.kept.send(demand_type).finished
    Stats::StatisticsService.instance.percentile(desired_percentile, demands_in_type.map(&:leadtime))
  end

  def active_and_kept_blocks
    demand_blocks.kept.active
  end

  def percentage_expedite
    return 0 if demands.kept.count.zero?

    (demands.kept.expedite.count.to_f / demands.kept.count.to_f) * 100
  end

  def percentage_standard
    return 0 if demands.kept.count.zero?

    (demands.kept.standard.count.to_f / demands.kept.count.to_f) * 100
  end

  def percentage_fixed_date
    return 0 if demands.kept.count.zero?

    (demands.kept.fixed_date.count.to_f / demands.kept.count.to_f) * 100
  end

  def percentage_intangible
    return 0 if demands.kept.count.zero?

    (demands.kept.intangible.count.to_f / demands.kept.count.to_f) * 100
  end

  def kept_demands_ids
    demands.kept.map(&:id)
  end

  private

  def no_pressure_set(date)
    finished? || cancelled? || remaining_days(date).zero? || total_days.zero? || backlog_remaining(date).zero?
  end

  def locate_last_results_for_date(date = Time.zone.today)
    @locate_last_results_for_date ||= project_results.until_week(date.to_date.cweek, date.to_date.cwyear).order(:result_date).last(2)
  end

  def regressive_hours_per_demand
    return avg_hours_per_demand if avg_hours_per_demand.positive?

    product.regressive_avg_hours_per_demand
  end

  def hour_value_project_value?
    return true if hour_value.present? || value.present?

    errors.add(:value, I18n.t('project.validations.no_value'))
    errors.add(:hour_value, I18n.t('project.validations.no_value'))
  end

  def product_required?
    return true if consulting? || training?

    errors.add(:product, I18n.t('project.validations.product_blank')) if outsourcing? && product.blank?
  end
end
