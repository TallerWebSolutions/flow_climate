# frozen_string_literal: true

RSpec.describe ProjectRiskConfig, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:risk_type).with(no_money_to_deadline: 0, backlog_growth_rate: 1, not_enough_available_hours: 2, profit_margin: 3, flow_pressure: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :risk_type }
    it { is_expected.to validate_presence_of :low_yellow_value }
    it { is_expected.to validate_presence_of :high_yellow_value }
  end
end
