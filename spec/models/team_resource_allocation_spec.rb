# frozen_string_literal: true

RSpec.describe TeamResourceAllocation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :team_resource }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :monthly_payment }
  end
end
