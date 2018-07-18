# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_custom_field_mappings
#
#  created_at                :datetime         not null
#  custom_field_machine_name :string           not null
#  demand_field              :integer          not null, indexed => [jira_account_id]
#  id                        :bigint(8)        not null, primary key
#  jira_account_id           :integer          not null, indexed, indexed => [demand_field]
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_jira_custom_field_mappings_on_jira_account_id  (jira_account_id)
#  unique_custom_field_to_jira_account                  (jira_account_id,demand_field) UNIQUE
#
# Foreign Keys
#
#  fk_rails_1c34addc50  (jira_account_id => jira_accounts.id)
#

module Jira
  class JiraCustomFieldMapping < ApplicationRecord
    enum demand_field: { class_of_service: 0, responsibles: 1 }

    belongs_to :jira_account, class_name: 'Jira::JiraAccount'

    validates :jira_account, :custom_field_machine_name, :demand_field, presence: true
    validates :demand_field, uniqueness: { scope: :jira_account_id, message: I18n.t('jira_custom_field_mapping.uniqueness.demand_field') }
  end
end
