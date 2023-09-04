# frozen_string_literal: true

module Mutations
    include Rails.application.routes.url_helpers

    class SynchronizeJiraProjectConfigMutation < Mutations::BaseMutation
      argument :id, ID, required: true
  
      field :id, ID, null: true
      field :status_message, Types::UpdateResponses, null: false

      def resolve(id:)
        jira_project_config = Jira::JiraProjectConfig.find_by_project_id(id: id)
        company = jira_project_config.jira_product_config.company
        jira_account = company.jira_accounts.first
  
        project_url = company_project_url(company, jira_project_config)

        if jira_project_config.present?
            Jira::ProcessJiraProjectJob.perform_later(jira_account, jira_project_config, current_user.email, current_user.full_name, project_url)
              { id: jira_project_config.id, status_message: 'SUCCESS' }        
    
          else
            { id: nil, status_message: 'NOT_FOUND' }
          end
      end
    end
  end
  