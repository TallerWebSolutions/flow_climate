# frozen_string_literal: true

RSpec.describe Stage, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:stage_type).with(design: 0, analysis: 1, development: 2, test: 3, homologation: 4, ready_to_deploy: 5, deployed: 6) }
    it { is_expected.to define_enum_for(:stage_stream).with(upstream: 0, downstream: 1) }
  end

  context 'associations' do
    it { is_expected.to have_and_belong_to_many(:projects) }
    it { is_expected.to have_many(:demand_transitions).dependent(:restrict_with_error) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :integration_id }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :stage_type }
    it { is_expected.to validate_presence_of :stage_stream }
  end
end
