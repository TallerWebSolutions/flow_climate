# frozen_string_literal: true

namespace :jira do
  desc 'jira updates'

  task update_projects: :environment do
    Project.executing.each do |p|
      jira_account = p.company.jira_accounts.first
      jira_config = p.jira_project_configs.first

      next if jira_config.blank? || jira_account.blank?

      Jira::ProcessJiraProjectJob.perform_later(jira_account, jira_config, nil, nil, nil)
    end
  end
end
