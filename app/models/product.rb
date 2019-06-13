# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  created_at     :datetime         not null
#  customer_id    :integer          not null, indexed, indexed => [name]
#  id             :bigint(8)        not null, primary key
#  name           :string           not null, indexed => [customer_id]
#  projects_count :integer          default(0)
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_products_on_customer_id           (customer_id)
#  index_products_on_customer_id_and_name  (customer_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_252452a41b  (customer_id => customers.id)
#

class Product < ApplicationRecord
  include ProjectAggregator

  belongs_to :customer, counter_cache: true
  has_many :projects, dependent: :restrict_with_error
  has_many :teams, -> { distinct }, through: :projects

  validates :name, :customer, presence: true
  validates :name, uniqueness: { scope: :customer, message: I18n.t('product.name.uniqueness') }

  delegate :name, to: :customer, prefix: true

  def regressive_avg_hours_per_demand
    return avg_hours_per_demand if avg_hours_per_demand.positive?

    customer.regressive_avg_hours_per_demand
  end
end
