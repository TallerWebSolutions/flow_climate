# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint           not null, primary key
#  automatic_renewal :boolean          default(FALSE)
#  end_date          :date
#  hours_per_demand  :integer          default(1), not null
#  renewal_period    :integer          default("monthly"), not null
#  start_date        :date             not null
#  total_hours       :integer          not null
#  total_value       :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  contract_id       :integer
#  customer_id       :integer          not null
#  product_id        :integer          not null
#
# Indexes
#
#  index_contracts_on_contract_id  (contract_id)
#  index_contracts_on_customer_id  (customer_id)
#  index_contracts_on_product_id   (product_id)
#
# Foreign Keys
#
#  fk_rails_4bd5aca47c  (contract_id => contracts.id)
#  fk_rails_a00d802491  (customer_id => customers.id)
#  fk_rails_d9e2e7cf99  (product_id => products.id)
#
class Contract < ApplicationRecord
  enum renewal_period: { monthly: 0, yearly: 1 }

  belongs_to :contract
  belongs_to :customer
  belongs_to :product

  has_many :contract_consolidations, dependent: :destroy, class_name: 'Consolidations::ContractConsolidation'
  has_many :demands, dependent: :nullify
  has_many :contract_estimation_change_histories, dependent: :destroy

  validates :customer, :product, :start_date, :total_hours, :total_value, :renewal_period, :hours_per_demand, presence: true

  scope :active, ->(date) { where('start_date <= :limit_date AND end_date >= :limit_date', limit_date: date) }

  delegate :name, to: :product, prefix: true
  delegate :company, to: :customer

  after_create :save_new_estimation_change_history
  before_update :save_estimation_change_history

  def hour_value
    total_value / total_hours
  end

  def estimated_scope
    total_hours / hours_per_demand
  end

  def current_hours_per_demand
    demands_finished = customer.demands.kept.finished.finished_after_date(start_date).finished_until_date(end_date)
    return 0 if demands_finished.blank?

    demands_finished.map(&:total_effort).compact.sum / demands_finished.count
  end

  def current_estimate_gap
    (current_hours_per_demand - hours_per_demand) / hours_per_demand.to_f
  end

  def remaining_work(date = Time.zone.today.end_of_month)
    delivered_to_date = demands.kept.where('end_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: date).count

    estimated_scope - delivered_to_date
  end

  def remaining_weeks(date = Time.zone.today.end_of_week)
    start_date_limit = [start_date, date].max
    return 0 if end_date < start_date_limit

    ((start_date_limit.end_of_week.upto(end_date.to_date.end_of_week).count.to_f + 1) / 7).round + 1
  end

  def hours_per_demand_to_date(date = Time.zone.today.end_of_day)
    change_histories = contract_estimation_change_histories.where('change_date <= :date', date: date).order(:change_date)
    return change_histories.last.hours_per_demand if change_histories.present?

    hours_per_demand
  end

  def flow_pressure(date = Time.zone.today.end_of_day)
    days_between = TimeService.instance.days_between_of(date, end_date)
    return 0 if demands.not_started.blank? || days_between.count.zero?

    demands.not_started.count.to_f / days_between.count
  end

  def avg_hours_per_month
    end_date = [end_date, Time.zone.today].compact.min
    months = TimeService.instance.months_between_of(start_date, end_date)

    demands.kept.finished.sum(&:total_effort) / months.count
  end

  private

  def save_estimation_change_history
    ContractEstimationChangeHistory.create(contract: self, change_date: Time.zone.now, hours_per_demand: hours_per_demand) if hours_per_demand != hours_per_demand_was
  end

  def save_new_estimation_change_history
    ContractEstimationChangeHistory.create(contract: self, change_date: Time.zone.now, hours_per_demand: hours_per_demand)
  end
end
