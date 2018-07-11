# frozen_string_literal: true

RSpec.describe Jira::ProjectJiraConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :team }
  end
  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :jira_account_domain }
    it { is_expected.to validate_presence_of :jira_project_key }
  end
end
