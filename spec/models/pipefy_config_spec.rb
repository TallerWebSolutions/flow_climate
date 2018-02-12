# frozen_string_literal: true

RSpec.describe PipefyConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :pipe_id }
    it { is_expected.to validate_presence_of :team }
  end
end
