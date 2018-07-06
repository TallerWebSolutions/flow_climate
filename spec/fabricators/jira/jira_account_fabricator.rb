# frozen_string_literal: true

Fabricator(:jira_account, from: 'Jira::JiraAccount') do
  company
  username { Faker::Internet.user_name }
  password { Faker::Internet.password }
  base_uri { Faker::Internet.url }
end
