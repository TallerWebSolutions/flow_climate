# frozen_string_literal: true

RSpec.describe Consolidations::ContractConsolidation do
  context 'associations' do
    it { is_expected.to belong_to :contract }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :consolidation_date }
    it { is_expected.to validate_presence_of :operational_risk_value }
  end
end
