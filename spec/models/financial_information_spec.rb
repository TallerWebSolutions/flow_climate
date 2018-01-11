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
end
