# frozen_string_literal: true

RSpec.describe ProjectRiskConfig, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:risk_type).with(no_money_to_deadline: 0, backlog_growth_rate: 1, not_enough_available_hours: 2, profit_margin: 3, flow_pressure: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :risk_type }
    it { is_expected.to validate_presence_of :low_yellow_value }
    it { is_expected.to validate_presence_of :high_yellow_value }
  end

  describe '#activate' do
    let(:risk_config) { Fabricate :project_risk_config, active: false }
    before { risk_config.activate! }
    it { expect(risk_config.reload.active).to be true }
  end

  describe '#deactivate' do
    let(:risk_config) { Fabricate :project_risk_config, active: true }
    before { risk_config.deactivate! }
    it { expect(risk_config.reload.active).to be false }
  end
end
