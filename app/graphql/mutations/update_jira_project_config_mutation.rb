# frozen_string_literal: true

module Mutations
  class UpdateJiraProjectConfigEditMutation < Mutations::BaseMutation
    argument :jira_product_key, String, required: true
    argument :fix_version_name, String, required: true
    argument :id, String, required: true

    field :id, String, null: false
    field :status_message, String, null: false

    def resolve(jira_product_key:, fix_version_name:, id:)
      jira_project_config = JiraProjectConfig.find_by(id: id)

      if jira_project_config.update(jira_product_key: jira_product_key, fix_version_name: fix_version_name)
        { id: jira_project_config.id, status_message: 'SUCCESS' }
      else
        { id: nil, status_message: 'FAIL' }
      end
    end
  end
end
