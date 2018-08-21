# frozen_string_literal: true

module Jira
  class ProcessJiraProjectJob < ApplicationJob
    def perform(jira_account, project_jira_key)
      project = Jira::JiraApiService.new(jira_account).request_project(project_jira_key)

      project.issues.each do |jira_issue|
        next if jira_issue.attrs['key'].blank?
        jira_issue_with_transitions = Jira::JiraApiService.new(jira_account).request_issue_details(jira_issue.attrs['key'])
        Jira::JiraIssueAdapter.instance.process_issue!(jira_account, project, jira_issue_with_transitions)
      end
    end
  end
end
