# frozen_string_literal: true

Fabricator(:jira_portfolio_unit_config, from: 'Jira::JiraPortfolioUnitConfig') do
  portfolio_unit

  jira_field_name { Faker::Company.name }
end
