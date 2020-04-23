# frozen_string_literal: true

# == Schema Information
#
# Table name: portfolio_units
#
#  id                  :bigint           not null, primary key
#  name                :string           not null
#  portfolio_unit_type :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :integer
#  product_id          :integer          not null
#
# Indexes
#
#  index_portfolio_units_on_name                 (name)
#  index_portfolio_units_on_name_and_product_id  (name,product_id) UNIQUE
#  index_portfolio_units_on_parent_id            (parent_id)
#  index_portfolio_units_on_portfolio_unit_type  (portfolio_unit_type)
#  index_portfolio_units_on_product_id           (product_id)
#
# Foreign Keys
#
#  fk_rails_111d0b277b  (product_id => products.id)
#  fk_rails_2af43d471c  (parent_id => portfolio_units.id)
#

class PortfolioUnit < ApplicationRecord
  include DemandsAggregator

  enum portfolio_unit_type: { product_module: 0, key_result: 1, source: 2, epic: 4 }

  belongs_to :product
  belongs_to :parent, class_name: 'PortfolioUnit', foreign_key: :parent_id, inverse_of: :children
  has_many :children, class_name: 'PortfolioUnit', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  has_many :demands, dependent: :nullify

  has_one :jira_portfolio_unit_config, class_name: 'Jira::JiraPortfolioUnitConfig', dependent: :destroy
  accepts_nested_attributes_for :jira_portfolio_unit_config, reject_if: :all_blank

  validates :product, :portfolio_unit_type, :name, presence: true
  validates :name, uniqueness: { scope: :product, message: I18n.t('portfolio_unit.validations.name') }

  scope :root_units, -> { where(parent: nil) }

  delegate :name, to: :parent, allow_nil: true, prefix: true

  def children?
    children.present?
  end

  def parent_branches
    portfolio_unit_parent = self

    product_tree_array = []
    until (portfolio_unit_parent = portfolio_unit_parent.parent).nil?
      product_tree_array << portfolio_unit_parent
    end
    product_tree_array
  end

  def total_portfolio_demands
    Demand.where(id: (demands.kept + children.map(&:total_portfolio_demands).flatten).flatten.map { |demand| demand['id'] })
  end

  def percentage_complete
    return 0 unless total_portfolio_demands.count.positive?

    total_portfolio_demands.finished.count.to_f / total_portfolio_demands.count
  end

  def total_cost
    total_portfolio_demands.sum(&:cost_to_project)
  end

  def total_hours
    total_portfolio_demands.sum(&:total_effort)
  end
end
