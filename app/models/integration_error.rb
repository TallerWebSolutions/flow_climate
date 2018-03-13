# frozen_string_literal: true

# == Schema Information
#
# Table name: integration_errors
#
#  id                     :integer          not null, primary key
#  company_id             :integer          not null
#  occured_at             :datetime         not null
#  integration_type       :integer          not null
#  integration_error_text :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_integration_errors_on_company_id        (company_id)
#  index_integration_errors_on_integration_type  (integration_type)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class IntegrationError < ApplicationRecord
  enum integration_type: { pipefy: 0 }

  belongs_to :company

  validates :company, :integration_type, :integration_error_text, presence: true
end
