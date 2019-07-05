# frozen_string_literal: true

Fabricator(:jira_product_config, from: 'Jira::JiraProductConfig') do
  product
  company

  jira_product_key { Faker::Name.first_name }
end
