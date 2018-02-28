# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id            :integer          not null, primary key
#  customer_id   :integer          not null
#  name          :string           not null
#  status        :integer          not null
#  project_type  :integer          not null
#  start_date    :date             not null
#  end_date      :date             not null
#  value         :decimal(, )
#  qty_hours     :decimal(, )
#  hour_value    :decimal(, )
#  initial_scope :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  product_id    :integer
#
# Indexes
#
#  index_projects_on_customer_id          (customer_id)
#  index_projects_on_product_id_and_name  (product_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (product_id => products.id)
#

class Project < ApplicationRecord
  enum status: { waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4 }
  enum project_type: { outsourcing: 0, consulting: 1, training: 2 }

  belongs_to :customer, counter_cache: true
  belongs_to :product, counter_cache: true

  has_many :project_results, dependent: :restrict_with_error
  has_many :project_risk_configs, dependent: :destroy
  has_many :project_risk_alerts, dependent: :destroy
  has_many :demands, dependent: :restrict_with_error
  has_one :pipefy_config, dependent: :destroy, autosave: true
  has_and_belongs_to_many :stages

  validates :customer, :qty_hours, :project_type, :name, :status, :start_date, :end_date, :status, :initial_scope, presence: true
  validates :name, uniqueness: { scope: :product, message: I18n.t('project.name.uniqueness') }
  validate :hour_value_project_value?, :product_required?

  delegate :name, to: :customer, prefix: true
  delegate :name, to: :product, prefix: true, allow_nil: true

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
    return "#{customer_name} | #{product_name} | #{name}" if product.present?
    "#{customer_name} | #{name}"
  end

  def total_days
    (end_date - start_date).to_i + 1
  end

  def remaining_days(from_date = Time.zone.today)
    return 0 if end_date < from_date || end_date < from_date
    return (end_date - start_date).to_i if start_date > from_date.to_date
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
    locate_last_results.first&.known_scope || initial_scope
  end

  def last_week_scope
    locate_last_results.last&.known_scope || initial_scope
  end

  def backlog_unit_growth
    last_week_scope - penultimate_week_scope
  end

  def backlog_growth_rate
    return 0 if locate_last_results.first.blank? || locate_last_results.first.known_scope.zero?
    backlog_unit_growth.to_f / locate_last_results.first.known_scope.to_f
  end

  def backlog_for(date)
    return initial_scope if date.blank?
    project_results.for_week(date.to_date.cweek, date.to_date.cwyear).last&.known_scope || initial_scope
  end

  def current_team
    project_results.order(result_date: :desc)&.first&.team
  end

  def flow_pressure
    return 0 if finished? || cancelled?
    days = remaining_days || total_days
    total_gap.to_f / days.to_f
  end

  def total_throughput
    project_results.sum(&:throughput)
  end

  def total_throughput_for(date)
    return total_throughput if date.blank?
    project_results.for_week(date.to_date.cweek, date.to_date.cwyear).sum(:throughput)
  end

  def total_throughput_until(date)
    return total_throughput if date.blank?
    project_results.until_week(date.to_date.cweek, date.to_date.cwyear).sum(:throughput)
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

  # Higher than 1 -> more hours required than available
  # Equal 1 -> enough hours to finish the scope
  # Between 0 and 1 -> more available hours than required
  #   if we have a result of 20% (0,2) means that we have 80% over the required hours
  #   if we have a result of 120% (1,2) means that we have 20% of the required hours over the available hours (20% is missing)
  def required_hours_per_available_hours
    required_hours.to_f / remaining_hours.to_f
  end

  def total_bugs_opened
    project_results.sum(&:qty_bugs_opened)
  end

  def total_bugs_closed
    project_results.sum(&:qty_bugs_closed)
  end

  def total_hours_bug
    project_results.sum(&:qty_hours_bug)
  end

  def avg_leadtime
    project_results.average(:leadtime)
  end

  def avg_hours_per_demand
    return 0 if project_results.empty?
    (total_hours_consumed.to_f / total_throughput.to_f)
  end

  def total_gap
    last_week_scope - total_throughput
  end

  def required_hours
    total_gap * regressive_hours_per_demand
  end

  def remaining_hours
    qty_hours - total_hours_consumed
  end

  def risk_color
    return 'green' if project_risk_alerts.empty?
    project_risk_alerts.order(:created_at).last.alert_color
  end

  def money_per_deadline
    percentage_remaining_money / percentage_remaining_days
  end

  # Determines if the backlog growth is above the throughput
  # the rate represents how many times the growth was over the throughput
  # One is a bad value since the project is not *burning* backlog when the rate is one.
  # Values under one means backlog burning
  def backlog_growth_throughput_rate
    return backlog_unit_growth if total_throughput_for(Time.zone.today).to_f.zero?
    backlog_unit_growth.to_f / total_throughput_for(Time.zone.today).to_f
  end

  def last_alert_for(risk_type)
    project_risk_alerts.joins(:project_risk_config).where('project_risk_configs.risk_type = :risk_type', risk_type: ProjectRiskConfig.risk_types[risk_type]).order(created_at: :desc).first
  end

  def average_demand_cost
    return 0 if project_results.blank?
    project_results.order(:result_date).last.average_demand_cost
  end

  def hours_per_month
    qty_hours.to_f / (total_days.to_f / 30)
  end

  def money_per_month
    value / (total_days.to_f / 30)
  end

  private

  def locate_last_results
    @last_results ||= project_results.until_week(Time.zone.today.cweek, Time.zone.today.cwyear).order(:result_date).last(2)
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
