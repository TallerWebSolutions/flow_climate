# frozen_string_literal: true

RSpec.describe ContractConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :contract }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :contract }
    it { is_expected.to validate_presence_of :consolidation_date }
    it { is_expected.to validate_presence_of :operational_risk_value }
  end
end
