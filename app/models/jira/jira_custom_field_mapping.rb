# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_custom_field_mappings
#
#  created_at                :datetime         not null
#  custom_field_machine_name :string           not null
#  custom_field_type         :integer          not null, indexed => [jira_account_id]
#  id                        :bigint(8)        not null, primary key
#  jira_account_id           :integer          not null, indexed, indexed => [custom_field_type]
#  updated_at                :datetime         not null
#
# Foreign Keys
#
#  fk_rails_1c34addc50  (jira_account_id => jira_accounts.id)
#

module Jira
  class JiraCustomFieldMapping < ApplicationRecord
    enum custom_field_type: { class_of_service: 0, responsibles: 1 }

    belongs_to :jira_account, class_name: 'Jira::JiraAccount'

    validates :jira_account, :custom_field_machine_name, :custom_field_type, presence: true
    validates :custom_field_type, uniqueness: { scope: :jira_account_id, message: I18n.t('jira_custom_field_mapping.uniqueness.custom_field_type') }
  end
end
