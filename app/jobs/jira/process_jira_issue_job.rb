# frozen_string_literal: true

module Jira
  class ProcessJiraIssueJob < ApplicationJob
    queue_as :critical

    def perform(issue_key, jira_account, project, user_email, user_name, demand_url)
      return unless jira_account.company.active?

      started_time = Time.zone.now
      jira_con = Jira::JiraApiService.new(jira_account.username, jira_account.api_token, jira_account.base_uri)

      demand = Demand.find_by(company: jira_account.company, external_id: issue_key)

      jira_issue = jira_con.request_issue(issue_key)
      if jira_issue.attrs.present?
        product = Jira::JiraReader.instance.read_product(jira_issue.attrs, jira_account)
        demand = Jira::JiraIssueAdapter.instance.process_issue(jira_account, jira_issue, product, project)
        creator = MembershipsRepository.instance.find_or_create_by_name(demand.team, jira_issue.attrs['fields']['creator']['displayName'])

        max_results = 100
        start_at = 0
        new_page = true
        while new_page
          jira_issue_changelog = jira_con.request_issue_changelog(issue_key, start_at, max_results)
          Jira::JiraIssueAdapter.instance.process_jira_issue_changelog(jira_account, jira_issue_changelog, demand, creator.team_member)

          start_at += 100
          new_page = !jira_issue_changelog['isLast']
        end

        finished_time = Time.zone.now

        UserNotifierMailer.async_activity_finished(user_email, user_name, Demand.model_name.human.downcase, issue_key, started_time, finished_time, demand_url).deliver if user_email.present?
      elsif demand.present?
        demand.discard unless demand.discarded?
        DemandEffortService.instance.build_efforts_to_demand(demand)
      end
    end
  end
end
