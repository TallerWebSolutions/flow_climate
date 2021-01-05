# frozen_string_literal: true

RSpec.describe Consolidations::CustomerConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :customer }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :customer }
      it { is_expected.to validate_presence_of :consolidation_date }
    end

    context 'complex ones' do
      context 'uniqueness' do
        it 'invalidates the duplicated ones' do
          consolidation_date = 1.day.ago
          customer = Fabricate :customer
          Fabricate :customer_consolidation, customer: customer, consolidation_date: consolidation_date

          dup_consolidation = Fabricate.build :customer_consolidation, customer: customer, consolidation_date: consolidation_date
          valid_consolidation = Fabricate :customer_consolidation, customer: customer
          other_valid_consolidation = Fabricate :customer_consolidation, consolidation_date: consolidation_date

          expect(dup_consolidation.valid?).to be false
          expect(dup_consolidation.errors_on(:customer)).to eq [I18n.t('errors.messages.taken')]

          expect(valid_consolidation.valid?).to be true
          expect(other_valid_consolidation.valid?).to be true
        end
      end
    end
  end
end
