# frozen_string_literal: true

# == Schema Information
#
# Table name: operation_results
#
#  id                            :integer          not null, primary key
#  company_id                    :integer          not null
#  result_date                   :date             not null
#  people_billable_count         :integer          not null
#  operation_week_value          :decimal(, )      not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  available_hours               :integer          not null
#  delivered_hours               :integer          not null
#  total_th                      :integer          not null
#  total_opened_bugs             :integer          not null
#  total_accumulated_closed_bugs :integer          not null
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class OperationResult < ApplicationRecord
  belongs_to :company

  validates :result_date, :people_billable_count, :operation_week_value, :available_hours, :delivered_hours, :total_th, :total_opened_bugs, :total_accumulated_closed_bugs, presence: true
end
