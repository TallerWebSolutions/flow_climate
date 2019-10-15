# frozen_string_literal: true

# == Schema Information
#
# Table name: company_settings
#
#  company_id                   :integer          not null, indexed
#  created_at                   :datetime         not null
#  id                           :bigint(8)        not null, primary key
#  max_active_parallel_projects :integer          not null
#  max_flow_pressure            :decimal(, )      not null
#  updated_at                   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_6434bf6768  (company_id => companies.id)
#

class CompanySettings < ApplicationRecord
  belongs_to :company

  validates :company, :max_active_parallel_projects, :max_flow_pressure, presence: true
end
