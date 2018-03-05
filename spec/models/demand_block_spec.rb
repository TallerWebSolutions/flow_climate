# frozen_string_literal: true

RSpec.describe DemandBlock, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:demand) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand }
    it { is_expected.to validate_presence_of :demand_block_id }
    it { is_expected.to validate_presence_of :blocker_username }
    it { is_expected.to validate_presence_of :block_time }
    it { is_expected.to validate_presence_of :block_reason }
  end

  context '#callbacks' do
    describe '#before_update' do
      let(:demand_block) { Fabricate :demand_block, unblock_time: nil }
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
end
