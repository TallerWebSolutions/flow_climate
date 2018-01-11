# frozen_string_literal: true

# == Schema Information
#
# Table name: financial_informations
#
#  id             :integer          not null, primary key
#  company_id     :integer          not null
#  finances_date  :date             not null
#  income_total   :decimal(, )      not null
#  expenses_total :decimal(, )      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_financial_informations_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class FinancialInformation < ApplicationRecord
  belongs_to :company

  validates :finances_date, :income_total, :expenses_total, presence: true

  def financial_result
    income_total.to_f - expenses_total.to_f
  end
end
