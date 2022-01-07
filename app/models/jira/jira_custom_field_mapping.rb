# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_custom_field_mappings
#
#  id                        :bigint           not null, primary key
#  custom_field_machine_name :string           not null
#  custom_field_type         :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  jira_account_id           :integer          not null
#
# Indexes
#
#  index_jira_custom_field_mappings_on_jira_account_id  (jira_account_id)
#  unique_custom_field_to_jira_account                  (jira_account_id,custom_field_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_1c34addc50  (jira_account_id => jira_accounts.id)
#

module Jira
  class JiraCustomFieldMapping < ApplicationRecord
    enum custom_field_type: { class_of_service: 0, responsibles: 1, customer: 2, contract: 3 }

    belongs_to :jira_account, class_name: 'Jira::JiraAccount'

    validates :custom_field_machine_name, :custom_field_type, presence: true
    validates :custom_field_type, uniqueness: { scope: :jira_account_id, message: I18n.t('jira_custom_field_mapping.uniqueness.custom_field_type') }
  end
end
