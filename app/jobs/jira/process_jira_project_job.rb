# frozen_string_literal: true

module Jira
  class ProcessJiraProjectJob < ApplicationJob
    queue_as :low

    def perform(jira_account, jira_project_config, user_email = nil, user_name = nil, project_url = nil)
      started_time = Time.zone.now
      jira_product_key = jira_project_config.jira_product_config.jira_product_key
      project_issues = Jira::JiraApiService.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issues_by_fix_version(jira_product_key, jira_project_config.fix_version_name)

      processed_keys = []
      project_issues.each do |jira_issue|
        jira_issue_key = jira_issue.attrs['key']
        next if jira_issue_key.blank?

        Jira::ProcessJiraIssueJob.perform_later(jira_issue_key, jira_account, jira_project_config.project, nil, nil, nil)
        processed_keys << jira_issue_key
      end

      demands_not_processed = jira_project_config.project.demands.map(&:external_id) - processed_keys

      jira_project_config.project.demands.where(external_id: demands_not_processed).each do |demand|
        Jira::ProcessJiraIssueJob.perform_later(demand.external_id, jira_account, jira_project_config.project, nil, nil, nil)
      end

      finished_time = Time.zone.now
      UserNotifierMailer.async_activity_finished(user_email, user_name, Project.model_name.human.downcase, jira_product_key, started_time, finished_time, project_url).deliver if user_email.present? && user_name.present? && project_url.present?
    end
  end
end
