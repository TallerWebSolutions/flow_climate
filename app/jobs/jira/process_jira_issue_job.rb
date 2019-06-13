# frozen_string_literal: true

module Jira
  class ProcessJiraIssueJob < ApplicationJob
    def perform(jira_account, project, issue_key, user_email, user_name, demand_url)
      started_time = Time.zone.now
      jira_issue_with_transitions = Jira::JiraApiService.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue_details(issue_key)

      return if jira_issue_with_transitions.attrs['key'].blank?

      Jira::JiraIssueAdapter.instance.process_issue!(jira_account, project, jira_issue_with_transitions)

      finished_time = Time.zone.now

      UserNotifierMailer.sync_finished(user_email, user_name, Demand.model_name.human.downcase, issue_key, started_time, finished_time, demand_url).deliver if user_email.present?
    end
  end
end
