# frozen_string_literal: true

namespace :jira_errors do
  desc 'Process Jira integration errors'
  task process_api_errors: :environment do
    Jira::JiraApiError.where(processed: false).find_each do |jira_error|
      demand = jira_error.demand
      if demand.jira_api_errors.count > 5
        demand.jira_api_errors.map { |demand_jira_error| demand_jira_error.update(processed: true) }
      else
        jira_account = demand.company.jira_accounts.first
        project = demand.project
        Jira::ProcessJiraIssueJob.perform_later(demand.external_id, jira_account, project, '', '', '')

        jira_error.update(processed: true)
      end
    end
  end
end
