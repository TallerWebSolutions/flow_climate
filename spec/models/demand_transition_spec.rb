# frozen_string_literal: true

RSpec.describe DemandTransition, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:demand) }
    it { is_expected.to belong_to(:stage) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand }
    it { is_expected.to validate_presence_of :stage }
    it { is_expected.to validate_presence_of :last_time_in }
  end

  describe '#set_dates' do
    context 'when the stage is a commitment_point' do
      let(:stage) { Fabricate :stage, commitment_point: true, end_point: false }
      let(:demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-04 12:00:00') }
      let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }
      before { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: transition_date }
      it 'sets the commitment date and do not touch in the others' do
        expect(demand.reload.commitment_date).to eq transition_date
        expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
        expect(demand.reload.end_date).to be_nil
      end
    end
    context 'when the stage is an end_point' do
      let(:stage) { Fabricate :stage, commitment_point: false, end_point: true }
      let(:demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-04 12:00:00') }
      let(:transition_date) { Time.zone.parse('2018-03-13 12:00:00') }
      before { Fabricate :demand_transition, stage: stage, demand: demand, last_time_in: transition_date }
      it 'sets the commitment date and do not touch in the others' do
        expect(demand.reload.commitment_date).to be_nil
        expect(demand.reload.created_date).to eq Time.zone.parse('2018-02-04 12:00:00')
        expect(demand.reload.end_date).to eq transition_date
      end
    end
  end
end
