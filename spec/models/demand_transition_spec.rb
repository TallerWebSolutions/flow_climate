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
end
