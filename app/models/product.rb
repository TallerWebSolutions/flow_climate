# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  customer_id    :integer          not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  projects_count :integer          default(0)
#  team_id        :integer
#
# Indexes
#
#  index_products_on_customer_id           (customer_id)
#  index_products_on_customer_id_and_name  (customer_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (team_id => teams.id)
#

class Product < ApplicationRecord
  include ProjectAggregator

  belongs_to :customer, counter_cache: true
  belongs_to :team
  has_many :projects, dependent: :restrict_with_error

  validates :name, :customer, presence: true
  validates :name, uniqueness: { scope: :customer, message: I18n.t('product.name.uniqueness') }

  delegate :name, to: :customer, prefix: true

  def last_week_scope
    projects.sum(&:last_week_scope)
  end

  def regressive_avg_hours_per_demand
    return avg_hours_per_demand if avg_hours_per_demand.positive?
    customer.regressive_avg_hours_per_demand
  end
end
