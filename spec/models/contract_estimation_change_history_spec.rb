# frozen_string_literal: true

RSpec.describe ContractEstimationChangeHistory do
  context 'associations' do
    it { is_expected.to belong_to :contract }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :change_date }
    it { is_expected.to validate_presence_of :hours_per_demand }
  end
end
