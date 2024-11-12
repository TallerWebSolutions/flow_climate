# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_custom_field_mappings
#
#  id                        :integer          not null, primary key
#  jira_account_id           :integer          not null
#  custom_field_type         :integer          not null
#  custom_field_machine_name :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_jira_custom_field_mappings_on_jira_account_id  (jira_account_id)
#  unique_custom_field_to_jira_account                  (jira_account_id,custom_field_type) UNIQUE
#

module Jira
  class JiraCustomFieldMapping < ApplicationRecord
    enum :custom_field_type, { class_of_service: 0, responsibles: 1, customer: 2, contract: 3 }

    belongs_to :jira_account, class_name: 'Jira::JiraAccount'

    validates :custom_field_machine_name, :custom_field_type, presence: true
    validates :custom_field_type, uniqueness: { scope: :jira_account_id, message: I18n.t('jira_custom_field_mapping.uniqueness.custom_field_type') }
  end
end
