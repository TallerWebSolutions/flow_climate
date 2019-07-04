# frozen_string_literal: true

RSpec.describe Jira::JiraPortfolioUnitConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :portfolio_unit }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :portfolio_unit }
    it { is_expected.to validate_presence_of :jira_field_name }
  end
end
