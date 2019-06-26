# frozen_string_literal: true

Fabricator(:jira_project_config, from: 'Jira::JiraProjectConfig') do
  project

  fix_version_name { Faker::Name.first_name }
end
