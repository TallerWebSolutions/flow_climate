# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_accounts
#
#  id                     :bigint           not null, primary key
#  base_uri               :string           not null
#  customer_domain        :string           not null
#  encrypted_api_token    :string           not null
#  encrypted_api_token_iv :string           not null
#  username               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer          not null
#
# Indexes
#
#  index_jira_accounts_on_base_uri         (base_uri) UNIQUE
#  index_jira_accounts_on_company_id       (company_id)
#  index_jira_accounts_on_customer_domain  (customer_domain) UNIQUE
#
# Foreign Keys
#
#  fk_rails_b16d2de302  (company_id => companies.id)
#

module Jira
  class JiraAccount < ApplicationRecord
    belongs_to :company
    has_many :jira_custom_field_mappings, class_name: 'Jira::JiraCustomFieldMapping', dependent: :destroy, inverse_of: :jira_account

    attr_encrypted :api_token, key: Base64.decode64(Figaro.env.secret_key_32_encoded)

    validates :username, :api_token, :base_uri, :company, :customer_domain, presence: true
    validates :customer_domain, :base_uri, uniqueness: true

    def responsibles_custom_field
      jira_custom_field_mappings.find_by(custom_field_type: :responsibles)
    end

    def class_of_service_custom_field
      jira_custom_field_mappings.find_by(custom_field_type: :class_of_service)
    end
  end
end
