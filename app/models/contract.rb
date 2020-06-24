# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint           not null, primary key
#  automatic_renewal :boolean          default(FALSE)
#  end_date          :date
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

  validates :customer, :product, :start_date, :total_hours, :total_value, :renewal_period, presence: true

  scope :active, -> { where('end_date >= current_date') }

  delegate :name, to: :product, prefix: true

  def hour_value
    total_value / total_hours
  end
end
