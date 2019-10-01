# frozen_string_literal: true

RSpec.describe Jira::JiraProductConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many(:jira_project_configs).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :product }
    it { is_expected.to validate_presence_of :jira_product_key }
  end

  context 'uniqueness' do
    let(:product) { Fabricate :product }

    context 'product jira key to account domain and fix version name' do
      let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'bla' }

      context 'same jira account domain and fix version name' do
        let(:other_product_jira_config) { Fabricate.build :jira_product_config, product: product, jira_product_key: 'bla' }

        it 'does not accept the model' do
          expect(other_product_jira_config.valid?).to be false
          expect(other_product_jira_config.errors[:jira_product_key]).to eq [I18n.t('jira_product_config.validations.jira_product_key_uniqueness.message')]
        end

        context 'same fix version name' do
          let(:other_product_jira_config) { Fabricate.build :jira_product_config, jira_product_key: 'bla' }

          it { expect(other_product_jira_config.valid?).to be true }
        end

        context 'other jira product key' do
          let(:other_product_jira_config) { Fabricate.build :jira_product_config, jira_product_key: 'bla2' }

          it { expect(other_product_jira_config.valid?).to be true }
        end
      end
    end
  end
end
