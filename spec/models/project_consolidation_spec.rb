# frozen_string_literal: true

RSpec.describe ProjectConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :consolidation_date }
    it { is_expected.to validate_presence_of :project_aging }
  end
end
