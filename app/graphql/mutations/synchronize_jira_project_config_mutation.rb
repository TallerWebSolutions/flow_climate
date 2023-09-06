# frozen_string_literal: true

module Mutations
  class SynchronizeJiraProjectConfigMutation < Mutations::BaseMutation
    argument :project_id, ID, required: true

    field :id, ID, null: true
    field :status_message, Types::UpdateResponses, null: false

    def resolve(project_id:)
      jira_project_config = Jira::JiraProjectConfig.find_by(project_id: project_id)

      if jira_project_config.present?
        company = jira_project_config.jira_product_config.company
        jira_account = company.jira_accounts.first
        Jira::ProcessJiraProjectJob.perform_later(jira_account, jira_project_config, '', '', '')
        { id: jira_project_config.id, status_message: 'SUCCESS' }

      else
        { status_message: 'NOT_FOUND' }
      end
    end
  end
end
