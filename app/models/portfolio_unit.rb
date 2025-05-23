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
#  external_id         :string
#  parent_id           :integer
#  product_id          :integer          not null
#
# Indexes
#
#  idx_portfolio_unit_name                       (name,product_id,parent_id)
#  index_portfolio_units_on_external_id          (external_id)
#  index_portfolio_units_on_name                 (name)
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
  include Demandable

  enum :portfolio_unit_type, { product_module: 0, journey_stage: 1, theme: 2, epic: 4 }

  belongs_to :product
  belongs_to :parent, optional: true, class_name: 'PortfolioUnit', inverse_of: :children
  has_many :children, class_name: 'PortfolioUnit', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  has_many :demands, dependent: :nullify

  has_one :jira_portfolio_unit_config, class_name: 'Jira::JiraPortfolioUnitConfig', dependent: :destroy
  accepts_nested_attributes_for :jira_portfolio_unit_config, reject_if: :all_blank

  validates :portfolio_unit_type, :name, presence: true
  validates :name, uniqueness: { scope: %i[product parent], message: I18n.t('portfolio_unit.validations.name') }

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
    Demand.where(id: (demands.kept + children.map(&:total_portfolio_demands).flatten).flatten.pluck('id'))
  end

  def percentage_complete
    return 0 unless total_portfolio_demands.count.positive?

    total_portfolio_demands.kept.finished_until_date(Time.zone.now).count.to_f / total_portfolio_demands.count
  end

  def total_cost(start_date = nil, end_date = nil)
    demands = total_portfolio_demands
    demands = demands.finished_after_date(start_date) if start_date.present?
    demands = demands.finished_until_date(end_date) if end_date.present?

    demands.sum(&:cost_to_project)
  end

  def total_hours(start_date = nil, end_date = nil)
    demands = total_portfolio_demands
    demands = demands.finished_after_date(start_date) if start_date.present?
    demands = demands.finished_until_date(end_date) if end_date.present?

    demands.sum(&:total_effort)
  end

  def percentage_concluded
    demands_kept = total_portfolio_demands.kept
    finished = demands_kept.finished_until_date(Time.zone.now).count

    demands_count = demands_kept.count

    return 0 if demands_count.zero? || finished.zero?

    finished / demands_count.to_f
  end

  def lead_time_p80
    demands_finished = total_portfolio_demands.kept.finished_with_leadtime

    Stats::StatisticsService.instance.percentile(80, demands_finished.map(&:leadtime))
  end
end
