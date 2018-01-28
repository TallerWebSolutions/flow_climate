# frozen_string_literal: true

RSpec.describe ProjectRiskAlert, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:alert_color).with(green: 0, yellow: 1, red: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :project_risk_config }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :project_risk_config }
    it { is_expected.to validate_presence_of :alert_color }
    it { is_expected.to validate_presence_of :alert_value }
  end
end
