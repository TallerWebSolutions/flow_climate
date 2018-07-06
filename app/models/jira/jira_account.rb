# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_accounts
#
#  base_uri           :string           not null
#  company_id         :integer          not null, indexed
#  created_at         :datetime         not null
#  encrypted_password :string           not null
#  id                 :bigint(8)        not null, primary key
#  updated_at         :datetime         not null
#  username           :string           not null
#
# Indexes
#
#  index_jira_accounts_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_b16d2de302  (company_id => companies.id)
#

module Jira
  class JiraAccount < ApplicationRecord
    belongs_to :company
    has_many :project_jira_configs, class_name: 'Jira::ProjectJiraConfig', dependent: :destroy, inverse_of: :jira_account
    has_many :jira_custom_field_mappings, class_name: 'Jira::JiraCustomFieldMapping', dependent: :destroy, inverse_of: :jira_account

    attr_encrypted :password, key: Base64.decode64(Figaro.env.secret_key_32_encoded)

    validates :username, :password, :base_uri, :company, presence: true

    def responsibles_custom_field
      jira_custom_field_mappings.find_by(demand_field: :responsibles)
    end

    def class_of_service_custom_field
      jira_custom_field_mappings.find_by(demand_field: :class_of_service)
    end
  end
end
