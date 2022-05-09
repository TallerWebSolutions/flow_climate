# frozen_string_literal: true

RSpec.describe ProjectAdditionalHour, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :hours_type }
    it { is_expected.to validate_presence_of :hours }
  end
end
