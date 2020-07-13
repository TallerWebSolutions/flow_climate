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

  has_many :contract_consolidations, dependent: :destroy

  validates :customer, :product, :start_date, :total_hours, :total_value, :renewal_period, :hours_per_demand, presence: true

  scope :active, -> { where('start_date <= :limit_date AND end_date >= :limit_date', limit_date: Time.zone.today) }

  delegate :name, to: :product, prefix: true
  delegate :demands, to: :customer, prefix: false

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
end
