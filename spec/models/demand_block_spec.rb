# frozen_string_literal: true

RSpec.describe DemandBlock, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:demand) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand }
    it { is_expected.to validate_presence_of :demand_id }
    it { is_expected.to validate_presence_of :demand_block_id }
    it { is_expected.to validate_presence_of :blocker_username }
    it { is_expected.to validate_presence_of :block_time }
    it { is_expected.to validate_presence_of :block_reason }
  end

  context 'callbacks' do
    describe '#before_update' do
      let(:demand_block) { Fabricate :demand_block, block_time: Time.zone.yesterday }
      context 'when there is unblock_time' do
        before { demand_block.update(unblock_time: Time.zone.now) }
        it { expect(demand_block.reload.block_duration).not_to eq 0 }
      end
      context 'when there is no unblock_time' do
        before { demand_block.update(block_time: Time.zone.now) }
        it { expect(demand_block.reload.block_duration).to be_nil }
      end
    end
  end

  context 'scopes' do
    describe '.for_date_interval' do
      let!(:first_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: Time.zone.parse('2018-03-06 00:00') }
      let!(:second_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00') }
      let!(:out_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

      it { expect(DemandBlock.for_date_interval(Time.zone.parse('2018-03-05 23:00'), Time.zone.parse('2018-03-06 13:00'))).to match_array [first_demand_block, second_demand_block] }
    end
    describe '.open' do
      let!(:first_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-05 23:00') }
      let!(:second_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 10:00') }
      let!(:third_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

      it { expect(DemandBlock.open).to match_array [first_demand_block, second_demand_block] }
    end
    describe '.closed' do
      let!(:first_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-05 23:00') }
      let!(:second_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }
      let!(:third_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

      it { expect(DemandBlock.closed).to match_array [second_demand_block, third_demand_block] }
    end
    describe '.active' do
      let!(:first_demand_block) { Fabricate :demand_block, active: true }
      let!(:second_demand_block) { Fabricate :demand_block, active: true }
      let!(:third_demand_block) { Fabricate :demand_block, active: false }

      it { expect(DemandBlock.active).to match_array [first_demand_block, second_demand_block] }
    end
  end

  describe '#activate!' do
    let(:demand_block) { Fabricate :demand_block, active: false }
    before { demand_block.activate! }
    it { expect(demand_block.active?).to be true }
  end

  describe '#deactivate!' do
    let(:demand_block) { Fabricate :demand_block, active: true }
    before { demand_block.deactivate! }
    it { expect(demand_block.active?).to be false }
  end
end
