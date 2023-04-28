# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  products_count :integer          default(0)
#  projects_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  company_id     :integer          not null
#  customer_id    :integer
#
# Indexes
#
#  index_customers_on_company_id           (company_id)
#  index_customers_on_company_id_and_name  (company_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_4f8eb9d458  (customer_id => customers.id)
#  fk_rails_ef51a916ef  (company_id => companies.id)
#

class Customer < ApplicationRecord
  include Demandable

  belongs_to :company, counter_cache: true
  belongs_to :customer, optional: true

  has_many :products, dependent: :restrict_with_error
  has_many :demands, dependent: :nullify
  has_many :demand_blocks, -> { distinct }, through: :demands
  has_many :contracts, dependent: :restrict_with_error
  has_many :customer_consolidations, dependent: :destroy, class_name: 'Consolidations::CustomerConsolidation'
  has_many :customers_projects, dependent: :restrict_with_error
  has_many :projects, through: :customers_projects, dependent: :restrict_with_error
  has_many :customers_devise_customers, dependent: :destroy
  has_many :devise_customers, through: :customers_devise_customers, dependent: :destroy
  has_many :slack_configurations, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('customer.name.uniqueness') }

  def add_user(devise_customer)
    return if devise_customers.include?(devise_customer)

    devise_customers << devise_customer
  end

  def customer_product
    periods = TimeService.instance.months_between_of(6.months.ago.end_of_month, Time.zone.today)
    periods.map do |date|
      data = demands_by_periods(date)
      {
        bugs: (100 * data[:bugs_created_count]) / (data[:demands_created_count].nonzero? || 1),
        date: date.strftime('%Y-%m-%d')
      }
    end
  end

  def active?
    projects.active.present?
  end

  def exclusives_demands
    exclusive_demands_ids = (exclusive_projects.includes([:demands]).map(&:demands).flatten.map(&:id) + demands.map(&:id)).uniq
    Demand.where(id: exclusive_demands_ids)
  end

  def exclusive_projects
    @exclusive_projects ||= Project.where(id: projects.includes([:customers]).select { |p| p.customers == [self] }.map(&:id).flatten)
  end

  def active_exclusive_projects
    exclusive_projects.active
  end

  def total_value
    exclusive_projects.filter_map(&:value).sum
  end

  def total_flow_pressure(date = Time.zone.today)
    contracts.filter_map { |contract| contract.flow_pressure(date) }.sum
  end

  def remaining_money(end_date = Time.zone.today.end_of_day)
    exclusive_projects.filter_map { |project| project.remaining_money(end_date) }.sum
  end

  def larger_lead_times(number_of_weeks, number_of_records)
    demands = exclusives_demands.includes([:company]).includes([:project])

    if number_of_weeks <= 0
      demands.kept.finished_with_leadtime.order(leadtime: :desc).first(number_of_records)
    else
      demands.kept.finished_with_leadtime.where('end_date >= :limit_date', limit_date: number_of_weeks.weeks.ago).order(leadtime: :desc).first(number_of_records)
    end
  end

  def current_scope
    demands.kept.count + initial_scope
  end

  def initial_scope
    exclusive_projects.active.sum(&:initial_scope)
  end

  def start_date
    exclusives_demands.kept.order(:end_date).first&.end_date&.to_date || Time.zone.today
  end

  def end_date
    exclusives_demands.kept.finished_until_date(Time.zone.now).order(:end_date).last&.end_date&.to_date || Time.zone.today
  end

  def last_contract_end
    contracts.map(&:end_date).max
  end

  private

  def demands_by_periods(date)
    {
      bugs_created_count: demands.to_created_date(date, Time.zone.today.end_of_day).bug.size,
      demands_created_count: demands.to_created_date(date, Time.zone.today.end_of_day).size
    }
  end
end
