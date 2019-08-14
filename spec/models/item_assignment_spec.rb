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

  describe '#working_hours_until' do
    before { travel_to Time.zone.local(2019, 8, 13, 10, 0, 0) }

    after { travel_back }

    let(:item_assignment) { Fabricate :item_assignment, start_time: 2.days.ago }
    let(:other_item_assignment) { Fabricate :item_assignment, start_time: 3.days.ago, finish_time: 1.day.ago }

    it { expect(item_assignment.working_hours_until).to eq 12 }
    it { expect(other_item_assignment.working_hours_until).to eq 6 }
  end
end
