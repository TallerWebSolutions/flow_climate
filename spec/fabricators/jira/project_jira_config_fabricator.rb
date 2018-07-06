# frozen_string_literal: true

Fabricator(:project_jira_config, from: 'Jira::ProjectJiraConfig') do
  jira_account
  project
  team
end
