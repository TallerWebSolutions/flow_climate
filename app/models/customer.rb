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
  include DemandsAggregator

  belongs_to :company, counter_cache: true
  belongs_to :customer

  has_many :products, dependent: :restrict_with_error
  has_many :demands, dependent: :nullify
  has_many :contracts, dependent: :restrict_with_error
  has_and_belongs_to_many :projects, dependent: :restrict_with_error
  has_and_belongs_to_many :devise_customers, dependent: :destroy

  validates :company, :name, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('customer.name.uniqueness') }

  def add_user(devise_customer)
    return if devise_customers.include?(devise_customer)

    devise_customers << devise_customer
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
    exclusive_projects.map(&:value).compact.sum
  end

  def remaining_money(end_date = Time.zone.today.end_of_day)
    exclusive_projects.map { |project| project.remaining_money(end_date) }.compact.sum
  end

  def larger_lead_times(number_of_weeks, number_of_records)
    demands = exclusives_demands.includes([:company]).includes([:project])

    if number_of_weeks <= 0
      demands.kept.finished_with_leadtime.order(leadtime: :desc).first(number_of_records)
    else
      demands.kept.finished_with_leadtime.where('end_date >= :limit_date', limit_date: number_of_weeks.weeks.ago).order(leadtime: :desc).first(number_of_records)
    end
  end
end
