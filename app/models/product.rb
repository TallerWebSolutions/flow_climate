# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :integer          not null
#  customer_id :integer
#
# Indexes
#
#  index_products_on_company_id            (company_id)
#  index_products_on_company_id_and_slug   (company_id,slug) UNIQUE
#  index_products_on_customer_id           (customer_id)
#  index_products_on_customer_id_and_name  (customer_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_252452a41b  (customer_id => customers.id)
#  fk_rails_438d5b34ce  (company_id => companies.id)
#

class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :slug, use: :slugged

  include Demandable

  belongs_to :company
  belongs_to :customer, optional: true, counter_cache: true

  has_many :products_projects, dependent: :destroy
  has_many :projects, through: :products_projects, dependent: :destroy
  has_many :teams, -> { distinct }, through: :projects
  has_many :memberships, -> { distinct }, through: :teams
  has_many :jira_product_configs, class_name: 'Jira::JiraProductConfig', dependent: :destroy
  has_one :azure_product_config, class_name: 'Azure::AzureProductConfig', dependent: :destroy
  has_many :portfolio_units, dependent: :destroy
  has_many :demands, dependent: :restrict_with_error
  has_many :demand_blocks, through: :demands
  has_many :flow_events, through: :projects
  has_many :risk_reviews, dependent: :destroy
  has_many :service_delivery_reviews, dependent: :destroy
  has_many :contracts, dependent: :restrict_with_error
  has_one :score_matrix, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :customer, message: I18n.t('product.name.uniqueness') }

  delegate :name, to: :customer, prefix: true

  before_validation :define_slug

  def percentage_complete
    return 0 unless demands.count.positive?

    demands.kept.finished_until_date(Time.zone.now).count.to_f / demands.kept.count
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

  def score_matrix_questions
    return score_matrix.score_matrix_questions if score_matrix.present?

    ScoreMatrixQuestion.none
  end

  def remaining_backlog
    demands.kept.not_finished(Time.zone.now).count
  end

  def delivered_scope
    demands.kept.finished_until_date(Time.zone.now).count
  end

  def total_flow_pressure
    max_end_date = projects.active.filter_map(&:end_date).max

    return 0 if max_end_date.blank?

    remaining_time = max_end_date - Time.zone.today

    remaining_backlog / remaining_time.to_f
  end

  def percentage_remaining_scope
    remaining_backlog / demands.kept.count.to_f
  end

  private

  def define_slug
    self.slug = name&.parameterize
  end
end
