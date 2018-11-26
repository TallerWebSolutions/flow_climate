# frozen_string_literal: true

RSpec.describe ProjectWeeklyCost, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :monthly_cost_value }
  end
end
