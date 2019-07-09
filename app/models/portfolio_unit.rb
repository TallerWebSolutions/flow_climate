# frozen_string_literal: true

# == Schema Information
#
# Table name: portfolio_units
#
#  created_at          :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  name                :string           not null, indexed, indexed => [product_id]
#  parent_id           :integer          indexed
#  portfolio_unit_type :integer          not null, indexed
#  product_id          :integer          not null, indexed => [name], indexed
#  updated_at          :datetime         not null
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
  enum portfolio_unit_type: { product_module: 0, key_result: 1, source: 2, impact: 3, epic: 4 }

  belongs_to :product
  belongs_to :parent, class_name: 'PortfolioUnit', foreign_key: :parent_id, inverse_of: :children
  has_many :children, class_name: 'PortfolioUnit', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  has_many :demands, dependent: :nullify

  has_one :jira_portfolio_unit_config, class_name: 'Jira::JiraPortfolioUnitConfig', dependent: :destroy
  accepts_nested_attributes_for :jira_portfolio_unit_config, reject_if: :all_blank

  validates :product, :portfolio_unit_type, :name, presence: true

  validates :name, uniqueness: { scope: :product, message: I18n.t('portfolio_unit.validations.name') }

  delegate :name, to: :parent, allow_nil: true, prefix: true
end
