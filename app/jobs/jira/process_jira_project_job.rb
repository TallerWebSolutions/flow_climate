# frozen_string_literal: true

module Jira
  class ProcessJiraProjectJob < ApplicationJob
    def perform(jira_account, jira_project_config, user_email = nil, user_name = nil, project_url = nil)
      started_time = Time.zone.now
      jira_product_key = jira_project_config.jira_product_config.jira_product_key
      project_issues = Jira::JiraApiService.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issues_by_fix_version(jira_product_key, jira_project_config.fix_version_name)

      project_issues.each do |jira_issue|
        next if jira_issue.attrs['key'].blank?

        jira_issue_with_transitions = Jira::JiraApiService.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue_details(jira_issue.attrs['key'])
        Jira::JiraIssueAdapter.instance.process_issue!(jira_account, jira_project_config.jira_product_config.product, jira_project_config.project, jira_issue_with_transitions)
      end

      finished_time = Time.zone.now
      UserNotifierMailer.sync_finished(user_email, user_name, Project.model_name.human.downcase, jira_product_key, started_time, finished_time, project_url).deliver if user_email.present? && user_name.present? && project_url.present?
    end
  end
end
