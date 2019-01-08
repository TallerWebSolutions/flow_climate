# frozen_string_literal: true

RSpec.describe IntegrationError, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:integration_type).with_values(jira: 0) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :integration_type }
    it { is_expected.to validate_presence_of :integration_error_text }
  end

  describe '.build_integration_error' do
    let(:demand) { Fabricate :demand }
    let(:demand_transition) { Fabricate :demand_transition, demand: demand }
    it 'creates the integration error' do
      demand_transition.errors.add(:stage, 'error')
      integration_error = IntegrationError.build_integration_error(demand, demand_transition, :jira)
      expect(integration_error).to be_persisted
      expect(integration_error.integration_type).to eq 'jira'
      expect(integration_error.integration_error_text).to eq "[#{DemandTransition.human_attribute_name :stage} error]"
      expect(integration_error.integratable_model_name).to eq 'DemandTransition'
    end
  end
end
