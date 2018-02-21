# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_type).with(feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4) }
    it { is_expected.to define_enum_for(:class_of_service).with(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project_result }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project_result }
    it { is_expected.to validate_presence_of :created_date }
    it { is_expected.to validate_presence_of :demand_id }
    it { is_expected.to validate_presence_of :effort }
    it { is_expected.to validate_presence_of :demand_type }
    it { is_expected.to validate_presence_of :class_of_service }
  end
end
