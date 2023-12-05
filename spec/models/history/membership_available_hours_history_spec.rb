# frozen_string_literal: true

RSpec.describe History::MembershipAvailableHoursHistory do
  context 'for associations' do
    it { is_expected.to belong_to(:membership) }
  end

  context 'for validations' do
    it { is_expected.to validate_presence_of :available_hours }
    it { is_expected.to validate_presence_of :change_date }
  end

  context 'for scopes' do
    describe '.until_date' do
      it 'returns the histories until date' do
        first_history = Fabricate :membership_available_hours_history, change_date: 2.months.ago
        second_history = Fabricate :membership_available_hours_history, change_date: 3.months.ago
        third_history = Fabricate :membership_available_hours_history, change_date: 4.months.ago
        Fabricate :membership_available_hours_history, change_date: 15.days.ago

        expect(described_class.until_date(1.month.ago)).to contain_exactly(first_history, second_history, third_history)
      end
    end
  end
end
