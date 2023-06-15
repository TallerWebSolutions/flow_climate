# frozen_string_literal: true

module Mutations
  class UpdateJiraProjectConfigMutation < Mutations::BaseMutation
    argument :fix_version_name, String, required: true
    argument :id, ID, required: true

    field :id, ID, null: true
    field :status_message, Types::UpdateResponses, null: false

    def resolve(id:, fix_version_name:)
      jira_project_config = Jira::JiraProjectConfig.find_by(id: id)

      if jira_project_config.present?
        if jira_project_config.update(fix_version_name: fix_version_name)
          { id: jira_project_config.id, status_message: 'SUCCESS' }
        else
          { id: nil, status_message: 'FAIL' }
        end

      else
        { id: nil, status_message: 'NOT_FOUND' }
      end
    end
  end
end
