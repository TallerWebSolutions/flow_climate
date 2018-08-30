# frozen_string_literal: true

# == Schema Information
#
# Table name: financial_informations
#
#  company_id     :integer          not null, indexed
#  created_at     :datetime         not null
#  expenses_total :decimal(, )      not null
#  finances_date  :date             not null
#  id             :bigint(8)        not null, primary key
#  income_total   :decimal(, )      not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_financial_informations_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_573f757bcf  (company_id => companies.id)
#

class FinancialInformation < ApplicationRecord
  belongs_to :company

  validates :finances_date, :income_total, :expenses_total, presence: true

  scope :for_month, ->(month, year) { where('EXTRACT(MONTH FROM finances_date) = :month AND EXTRACT(YEAR FROM finances_date) = :year', month: month, year: year) }

  def financial_result
    income_total.to_f - expenses_total.to_f
  end

  def cost_per_hour
    return 0 if project_delivered_hours.zero?
    expenses_total / project_delivered_hours
  end

  def income_per_hour
    return 0 if project_delivered_hours.zero?
    income_total / project_delivered_hours
  end

  def hours_per_demand
    return 0 if throughput_in_month.zero?
    project_delivered_hours.to_f / throughput_in_month.to_f
  end

  def project_delivered_hours
    company.delivered_hours_for_month(finances_date).to_f
  end

  def throughput_in_month
    company.throughput_in_month(finances_date)
  end

  def red?
    expenses_total > income_total
  end
end
