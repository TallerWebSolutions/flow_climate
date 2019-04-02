# frozen_string_literal: true

RSpec.describe FlowImpact, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:impact_type).with_values(other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:demand) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :impact_type }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :impact_description }
  end
end
