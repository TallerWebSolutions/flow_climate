# frozen_string_literal: true

# == Schema Information
#
# Table name: operation_weekly_results
#
#  id                   :integer          not null, primary key
#  company_id           :integer          not null
#  result_date          :date             not null
#  billable_count       :integer          not null
#  operation_week_value :decimal(, )      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class OperationWeeklyResult < ApplicationRecord
  belongs_to :company

  validates :result_date, :billable_count, :operation_week_value, presence: true
end
