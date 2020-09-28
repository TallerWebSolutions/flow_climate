# frozen_string_literal: true

namespace :project_alerts do
  desc 'Process projects alerts'
  task process_alerts: :environment do
    Jira::JiraApiError.where(processed: false).each do |jira_error|
      demand = jira_error.project
      jira_account = demand.company.jira_accounts.first
      project = demand.project
      Jira::ProcessJiraIssueJob.perform_later(jira_account, project, demand.external_id, '', '', '')

      jira_error.update(processed: true)
    end
  end
end
