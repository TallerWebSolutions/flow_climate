# frozen_string_literal: true

RSpec.describe PipefyConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :pipe_id }
    it { is_expected.to validate_presence_of :team }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team).with_prefix }
    it { is_expected.to delegate_method(:full_name).to(:project).with_prefix }
  end
end
