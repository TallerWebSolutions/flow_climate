# frozen_string_literal: true

RSpec.describe Contract, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:renewal_period).with_values(monthly: 0, yearly: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :contract }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :customer }
    it { is_expected.to validate_presence_of :product }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :total_hours }
    it { is_expected.to validate_presence_of :renewal_period }
  end

  context 'scope' do
    pending 'active'
  end

  pending 'hour_value'
end
