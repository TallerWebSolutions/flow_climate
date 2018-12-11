# frozen_string_literal: true

module Jira
  class ProcessJiraIssueJob < ApplicationJob
    def perform(jira_account, project, issue_key)
      jira_issue_with_transitions = Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_issue_details(issue_key)

      return if jira_issue_with_transitions.attrs['key'].blank?

      Jira::JiraIssueAdapter.instance.process_issue!(jira_account, project, jira_issue_with_transitions)
    end
  end
end
