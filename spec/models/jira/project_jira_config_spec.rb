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

  context 'uniqueness' do
    context 'project jira key to account domain and fix version name' do
      let!(:project_jira_config) { Fabricate :project_jira_config, jira_project_key: 'bla', jira_account_domain: 'foo', fix_version_name: 'bar' }

      context 'same jira account domain and fix version name' do
        let(:other_project_jira_config) { Fabricate.build :project_jira_config, jira_project_key: 'bla', jira_account_domain: 'foo', fix_version_name: 'bar' }

        it 'does not accept the model' do
          expect(other_project_jira_config.valid?).to be false
          expect(other_project_jira_config.errors[:jira_project_key]).to eq [I18n.t('project_jira_config.validations.jira_project_key_uniqueness.message')]
        end
        context 'same fix version name' do
          let(:other_project_jira_config) { Fabricate.build :project_jira_config, jira_project_key: 'bla', jira_account_domain: 'foo2', fix_version_name: 'bar' }
          it { expect(other_project_jira_config.valid?).to be true }
        end
        context 'other jira project key' do
          let(:other_project_jira_config) { Fabricate.build :project_jira_config, jira_project_key: 'bla2', jira_account_domain: 'foo', fix_version_name: 'bar' }
          it { expect(other_project_jira_config.valid?).to be true }
        end
      end
    end
  end
end
