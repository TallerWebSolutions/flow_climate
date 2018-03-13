# frozen_string_literal: true

RSpec.describe PipefyTeamConfig, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:member_type).with(developer: 0, analyst: 1, designer: 2, customer: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :team }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_presence_of :integration_id }
  end
end
