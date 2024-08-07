# frozen_string_literal: true

RSpec.describe Jira::JiraPortfolioUnitConfig do
  context 'associations' do
    it { is_expected.to belong_to :portfolio_unit }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :jira_field_name }
  end
end
