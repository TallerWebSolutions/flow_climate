# frozen_string_literal: true

# == Schema Information
#
# Table name: project_risk_configs
#
#  id                :integer          not null, primary key
#  company_id        :integer          not null
#  risk_type         :integer          not null
#  high_yellow_value :decimal(, )      not null
#  low_yellow_value  :decimal(, )      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_project_risk_configs_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class ProjectRiskConfig < ApplicationRecord
  enum risk_type: { no_money_to_deadline: 0, backlog_grouth_date: 1, not_enough_available_hours: 2, profit_margin: 3 }

  belongs_to :company

  validates :company, :risk_type, :high_yellow_value, :low_yellow_value, presence: true
end
