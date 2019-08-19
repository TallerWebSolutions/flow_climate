# frozen_string_literal: true

RSpec.describe Membership, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:member_role).with_values(developer: 0, manager: 1, client: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :team_member }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :team_member }
    it { is_expected.to validate_presence_of :start_date }
  end

  context 'scopes' do
    describe '.active' do
      let(:active) { Fabricate :membership, end_date: nil }
      let(:other_active) { Fabricate :membership, end_date: nil }
      let(:inactive) { Fabricate :membership, active: false }

      it { expect(described_class.active).to match_array [active, other_active] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team_member).with_prefix }
    it { is_expected.to delegate_method(:jira_account_id).to(:team_member) }
    it { is_expected.to delegate_method(:monthly_payment).to(:team_member) }
  end

  describe '#hours_per_day' do
    let(:team_membership) { Fabricate :membership, hours_per_month: 60 }
    let(:other_membership) { Fabricate :membership, hours_per_month: nil }

    it { expect(team_membership.hours_per_day).to eq 2 }
    it { expect(other_membership.hours_per_day).to eq 0 }
  end
end
