# frozen_string_literal: true

# == Schema Information
#
# Table name: integration_errors
#
#  company_id              :integer          not null, indexed
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  integratable_model_name :string
#  integration_error_text  :string           not null
#  integration_type        :integer          not null, indexed
#  occured_at              :datetime         not null
#  project_id              :integer
#  updated_at              :datetime         not null
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
  enum integration_type: { pipefy: 0 }

  belongs_to :company
  belongs_to :project

  validates :company, :integration_type, :integration_error_text, presence: true

  def self.build_integration_error(demand, integratable, integration_type)
    IntegrationError.create!(company: demand.company, integratable_model_name: integratable.model_name, project: demand.project, integration_type: integration_type, integration_error_text: "[#{integratable.errors.full_messages.join(', ')}]")
  end
end
