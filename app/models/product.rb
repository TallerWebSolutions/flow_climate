# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  created_at  :datetime         not null
#  customer_id :integer          not null, indexed, indexed => [name]
#  id          :bigint(8)        not null, primary key
#  name        :string           not null, indexed => [customer_id]
#  updated_at  :datetime         not null
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
  has_and_belongs_to_many :projects, dependent: :destroy

  has_many :teams, -> { distinct }, through: :projects
  has_many :jira_product_configs, class_name: 'Jira::JiraProductConfig', dependent: :destroy
  has_many :portfolio_units, dependent: :destroy
  has_many :demands, dependent: :restrict_with_error
  has_many :demand_blocks, through: :demands
  has_many :flow_impacts, through: :projects
  has_many :risk_reviews, dependent: :destroy

  validates :name, :customer, presence: true
  validates :name, uniqueness: { scope: :customer, message: I18n.t('product.name.uniqueness') }

  delegate :name, to: :customer, prefix: true
  delegate :company, to: :customer, prefix: false

  def percentage_complete
    return 0 unless demands.count.positive?

    demands.finished.count.to_f / demands.count
  end

  def total_portfolio_demands
    demands.kept
  end

  def total_cost
    total_portfolio_demands.sum(&:cost_to_project)
  end

  def total_hours
    total_portfolio_demands.sum(&:total_effort)
  end
end
