# frozen_string_literal: true

Fabricator(:project_jira_config, from: 'Jira::ProjectJiraConfig') do
  project
  team

  jira_account_domain { Faker::Internet.domain_name }
  jira_project_key { Faker::Name.first_name }
end
