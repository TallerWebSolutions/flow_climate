# frozen_string_literal: true

RSpec.describe FinancialInformation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :finances_date }
    it { is_expected.to validate_presence_of :income_total }
    it { is_expected.to validate_presence_of :expenses_total }
  end

  describe '#financial_result' do
    let(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    it { expect(finances.financial_result).to eq 8.2 }
  end
end
