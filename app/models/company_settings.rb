# frozen_string_literal: true

# == Schema Information
#
# Table name: company_settings
#
#  id                           :integer          not null, primary key
#  company_id                   :integer          not null
#  max_active_parallel_projects :integer          not null
#  max_flow_pressure            :decimal(, )      not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_company_settings_on_company_id  (company_id)
#

class CompanySettings < ApplicationRecord
  belongs_to :company

  validates :max_active_parallel_projects, :max_flow_pressure, presence: true
end
