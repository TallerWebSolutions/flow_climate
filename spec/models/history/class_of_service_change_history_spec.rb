# frozen_string_literal: true

RSpec.describe History::ClassOfServiceChangeHistory, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:from_class_of_service).with_values(from_standard: 0, from_expedite: 1, from_fixed_date: 2, from_intangible: 3) }
    it { is_expected.to define_enum_for(:to_class_of_service).with_values(to_standard: 0, to_expedite: 1, to_fixed_date: 2, to_intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :change_date }
      it { is_expected.to validate_presence_of :to_class_of_service }
    end

    context 'complex ones' do
      context 'uniqueness' do
        it 'invalidates the duplicated ones' do
          change_date = 1.day.ago
          demand = Fabricate :demand
          Fabricate :class_of_service_change_history, demand: demand, change_date: change_date

          dup_history = Fabricate.build :class_of_service_change_history, demand: demand, change_date: change_date
          valid_history = Fabricate :class_of_service_change_history, demand: demand
          other_valid_history = Fabricate :class_of_service_change_history, change_date: change_date

          expect(dup_history.valid?).to be false
          expect(dup_history.errors_on(:demand)).to eq [I18n.t('errors.messages.taken')]

          expect(valid_history.valid?).to be true
          expect(other_valid_history.valid?).to be true
        end
      end
    end
  end
end
