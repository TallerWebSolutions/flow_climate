# frozen_string_literal: true

Fabricator(:jira_custom_field_mapping, from: 'Jira::JiraCustomFieldMapping') do
  jira_account
  demand_field { %i[responsibles class_of_service].sample }
  custom_field_machine_name { Faker::Internet.user_name }
end
