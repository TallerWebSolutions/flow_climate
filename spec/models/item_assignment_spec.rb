# frozen_string_literal: true

RSpec.describe ItemAssignment, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
    it { is_expected.to belong_to :team_member }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand }
    it { is_expected.to validate_presence_of :team_member }

    context 'uniqueness' do
      let(:team_member) { Fabricate :team_member }
      let(:demand) { Fabricate :demand }
      let!(:start_time) { 1.day.ago }
      let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: start_time }
      let!(:same_item_assignment) { Fabricate.build :item_assignment, demand: demand, team_member: team_member, start_time: start_time }

      let!(:other_demand_assignment) { Fabricate.build :item_assignment, team_member: team_member, start_time: start_time }
      let!(:other_member_assignment) { Fabricate.build :item_assignment, demand: demand, start_time: start_time }
      let!(:other_date_item_assignment) { Fabricate.build :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.now }

      it 'returns the model invalid with errors on duplicated field' do
        expect(same_item_assignment).not_to be_valid
        expect(same_item_assignment.errors_on(:demand)).to eq [I18n.t('item_assignment.validations.demand_unique')]
      end

      it { expect(other_date_item_assignment).to be_valid }
      it { expect(other_demand_assignment).to be_valid }
      it { expect(other_member_assignment).to be_valid }
    end
  end

  context 'scopes' do
    describe '.for_dates' do
      before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

      after { travel_back }

      context 'with data' do
        let!(:first_item_assignment) { Fabricate :item_assignment, start_time: 10.days.ago, finish_time: 7.days.ago }
        let!(:second_item_assignment) { Fabricate :item_assignment, start_time: 9.days.ago, finish_time: 8.days.ago }
        let!(:third_item_assignment) { Fabricate :item_assignment, start_time: 4.days.ago, finish_time: 1.day.ago }
        let!(:fourth_item_assignment) { Fabricate :item_assignment, start_time: 4.days.ago, finish_time: nil }

        it { expect(described_class.for_dates(10.days.ago, 7.days.ago)).to match_array [first_item_assignment, second_item_assignment] }
        it { expect(described_class.for_dates(169.hours.ago, 6.days.ago)).to eq [first_item_assignment] }
        it { expect(described_class.for_dates(5.days.ago, 2.days.ago)).to eq [third_item_assignment, fourth_item_assignment] }
        it { expect(described_class.for_dates(9.days.ago, 6.days.ago)).to eq [first_item_assignment, second_item_assignment] }
        it { expect(described_class.for_dates(4.days.ago, nil)).to eq [third_item_assignment, fourth_item_assignment] }
      end

      context 'with no data' do
        it { expect(described_class.for_dates(7.days.ago, 6.days.ago)).to eq [] }
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team_member).with_prefix }
  end

  describe '#working_hours_until' do
    before { travel_to Time.zone.local(2019, 8, 13, 10, 0, 0) }

    after { travel_back }

    let(:item_assignment) { Fabricate :item_assignment, start_time: 2.days.ago }
    let(:other_item_assignment) { Fabricate :item_assignment, start_time: 3.days.ago, finish_time: 1.day.ago }

    it { expect(item_assignment.working_hours_until).to eq 12 }
    it { expect(other_item_assignment.working_hours_until).to eq 6 }
  end
end
