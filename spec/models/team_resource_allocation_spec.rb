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

  context 'scopes' do
    let!(:active) { Fabricate :team_resource_allocation, end_date: nil }
    let!(:other_active) { Fabricate :team_resource_allocation, end_date: nil }
    let!(:inactive) { Fabricate :team_resource_allocation, end_date: Time.zone.today }

    describe '.active_for_date' do
      it { expect(described_class.active_for_date(Time.zone.yesterday)).to match_array [active, other_active, inactive] }
    end
  end
end
