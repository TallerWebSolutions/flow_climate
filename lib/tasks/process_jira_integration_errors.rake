# frozen_string_literal: true

namespace :jira_errors do
  desc 'Process Jira integration errors'
  task process_api_errors: :environment do
    Jira::JiraApiError.where(processed: false).each do |jira_error|
      demand = jira_error.demand
      if demand.jira_errors.count > 5
        demand.jira_errors.map { |jira_error| jira_error.update(processed: true) }
      else
        jira_account = demand.company.jira_accounts.first
        project = demand.project
        Jira::ProcessJiraIssueJob.perform_later(jira_account, project, demand.external_id, '', '', '')

        jira_error.update(processed: true)
      end
    end
  end
end
