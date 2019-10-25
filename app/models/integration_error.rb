# frozen_string_literal: true

# == Schema Information
#
# Table name: integration_errors
#
#  id                      :bigint           not null, primary key
#  integratable_model_name :string
#  integration_error_text  :string           not null
#  integration_type        :integer          not null
#  occured_at              :datetime         not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_id              :integer          not null
#  project_id              :integer
#
# Indexes
#
#  index_integration_errors_on_company_id        (company_id)
#  index_integration_errors_on_integration_type  (integration_type)
#
# Foreign Keys
#
#  fk_rails_3505c123da  (company_id => companies.id)
#  fk_rails_6533e9d0da  (project_id => projects.id)
#

class IntegrationError < ApplicationRecord
  enum integration_type: { jira: 0 }

  belongs_to :company
  belongs_to :project

  validates :company, :integration_type, :integration_error_text, presence: true
end
