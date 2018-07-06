# frozen_string_literal: true

RSpec.describe Jira::ProjectJiraConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :jira_account }
    it { is_expected.to belong_to :team }
  end
  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :jira_account }
    it { is_expected.to validate_presence_of :team }
  end
end
