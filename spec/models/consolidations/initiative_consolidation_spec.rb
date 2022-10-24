# frozen_string_literal: true

RSpec.describe Consolidations::InitiativeConsolidation do
  context 'associations' do
    it { is_expected.to belong_to :initiative }
  end

  context 'scopes' do
    describe '.outdated_consolidations' do
      it 'returns the outdated consolidations based on the given dates' do
        travel_to Time.zone.local(2022, 2, 5) do
          Fabricate :initiative_consolidation, consolidation_date: 3.weeks.ago
          Fabricate :initiative_consolidation, consolidation_date: 1.week.ago

          first_outdated_consolidation = Fabricate :initiative_consolidation, consolidation_date: 5.weeks.ago
          second_outdated_consolidation = Fabricate :initiative_consolidation, consolidation_date: Time.zone.now

          expect(described_class.outdated_consolidations(4.weeks.ago, 1.day.ago)).to match_array([first_outdated_consolidation, second_outdated_consolidation])
        end
      end
    end

    describe '.weekly_data' do
      it 'returns the outdated consolidations based on the given dates' do
        last_data_in_week_consolidation = Fabricate :initiative_consolidation, consolidation_date: 5.weeks.ago, last_data_in_week: true
        Fabricate :initiative_consolidation, consolidation_date: Time.zone.now

        expect(described_class.weekly_data).to match_array([last_data_in_week_consolidation])
      end
    end
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :consolidation_date }
    end

    context 'uniqueness' do
      it 'does not accept same initiative and same date' do
        test_date = Time.zone.today
        company = Fabricate :company
        initiative = Fabricate :initiative, company: company, name: 'bla'

        first_consolidation = Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: test_date
        second_consolidation = Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 2.days.ago
        third_consolidation = Fabricate :initiative_consolidation, consolidation_date: test_date
        fourth_consolidation = Fabricate.build :initiative_consolidation, initiative: initiative, consolidation_date: test_date

        expect(first_consolidation).to be_valid
        expect(second_consolidation).to be_valid
        expect(third_consolidation).to be_valid
        expect(fourth_consolidation).not_to be_valid
      end
    end
  end
end
