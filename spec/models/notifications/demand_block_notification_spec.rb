# frozen-string-literal: true

RSpec.describe Notifications::DemandBlockNotification, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand_block }
  end

  context 'enums' do
    it { is_expected.to define_enum_for(:block_state).with_values(blocked: 0, unblocked: 1) }
  end
end
