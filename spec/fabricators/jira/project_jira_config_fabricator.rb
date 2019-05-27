# frozen_string_literal: true

Fabricator(:project_jira_config, from: 'Jira::ProjectJiraConfig') do
  project

  jira_project_key { Faker::Name.first_name }
end
