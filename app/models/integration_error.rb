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
