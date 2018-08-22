# frozen_string_literal: true

module Jira
  class ProcessJiraProjectJob < ApplicationJob
    def perform(jira_account, project_jira_key)
      jira_project = Jira::JiraApiService.new(jira_account).request_project(project_jira_key)

      jira_project.issues.each do |jira_issue|
        next if jira_issue.attrs['key'].blank?
        project_jira_config = Jira::ProjectJiraConfig.find_by(jira_project_key: jira_project.attrs['key'], jira_account_domain: jira_account.customer_domain)
        jira_issue_with_transitions = Jira::JiraApiService.new(jira_account).request_issue_details(jira_issue.attrs['key'])
        Jira::JiraIssueAdapter.instance.process_issue!(jira_account, project_jira_config.project, jira_issue_with_transitions)
      end
    end
  end
end
