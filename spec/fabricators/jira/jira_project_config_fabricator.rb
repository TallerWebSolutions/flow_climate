# frozen_string_literal: true

Fabricator(:jira_project_config, from: 'Jira::JiraProjectConfig') do
  project
  jira_product_config

  fix_version_name { Faker::Name.first_name.gsub(/\W/, '') }
end
