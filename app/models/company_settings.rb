# frozen_string_literal: true

# == Schema Information
#
# Table name: company_settings
#
#  id                           :bigint           not null, primary key
#  max_active_parallel_projects :integer          not null
#  max_flow_pressure            :decimal(, )      not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  company_id                   :integer          not null
#
# Indexes
#
#  index_company_settings_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_6434bf6768  (company_id => companies.id)
#

class CompanySettings < ApplicationRecord
  belongs_to :company

  validates :max_active_parallel_projects, :max_flow_pressure, presence: true
end
