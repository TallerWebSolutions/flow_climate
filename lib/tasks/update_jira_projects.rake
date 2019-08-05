# frozen_string_literal: true

namespace :jira do
  desc 'jira updates'

  task update_projects: :environment do
    Jira::JiraProjectConfig.all.each do |jira_project_config|
      next unless jira_project_config.project.executing?

      jira_account = jira_project_config.jira_product_config.company.jira_accounts.first

      Jira::ProcessJiraProjectJob.perform_now(jira_account, jira_project_config, nil, nil, nil)
    end
  end
end
