# frozen_string_literal: true

RSpec.describe Jira::JiraProjectConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :jira_product_config }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :fix_version_name }
  end

  context 'uniqueness' do
    let(:jira_product_config) { Fabricate :jira_product_config }

    context 'project jira key to account domain and fix version name' do
      let!(:jira_project_config) { Fabricate :jira_project_config, jira_product_config: jira_product_config, fix_version_name: 'bar' }

      context 'same jira account domain and fix version name' do
        let(:other_jira_project_config) { Fabricate.build :jira_project_config, jira_product_config: jira_product_config, fix_version_name: 'bar' }

        it 'does not accept the model' do
          expect(other_jira_project_config.valid?).to be false
          expect(other_jira_project_config.errors[:fix_version_name]).to eq [I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message')]
        end

        context 'same fix version name' do
          let(:other_jira_project_config) { Fabricate.build :jira_project_config, fix_version_name: 'bar' }

          it { expect(other_jira_project_config.valid?).to be true }
        end

        context 'other jira project key' do
          let(:other_jira_project_config) { Fabricate.build :jira_project_config, jira_product_config: jira_product_config, fix_version_name: 'xpto' }

          it { expect(other_jira_project_config.valid?).to be true }
        end
      end
    end
  end
end
