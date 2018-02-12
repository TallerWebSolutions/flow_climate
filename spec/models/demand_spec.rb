# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_type).with(feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project_result }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand_id }
    it { is_expected.to validate_presence_of :effort }
  end
end
