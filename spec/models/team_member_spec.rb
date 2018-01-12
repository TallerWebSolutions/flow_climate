# frozen_string_literal: true

RSpec.describe TeamMember, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:billable_type).with(outsourcing: 0, consulting: 1, training: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :monthly_payment }
    it { is_expected.to validate_presence_of :hours_per_month }
  end
end
