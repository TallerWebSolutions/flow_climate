# frozen_string_literal: true

RSpec.describe ProjectAdditionalHour, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:hours_type).with_values(meeting: 0) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :hours_type }
    it { is_expected.to validate_presence_of :event_date }
    it { is_expected.to validate_presence_of :hours }
  end
end
