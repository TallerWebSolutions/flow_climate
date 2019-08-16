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

    context 'uniqueness' do
      let(:team) { Fabricate :team }
      let(:team_member) { Fabricate :team_member }

      let!(:first_membership) { Fabricate :membership, team: team, team_member: team_member }
      let!(:second_membership) { Fabricate.build :membership, team: team, team_member: team_member }
      let!(:third_membership) { Fabricate.build :membership, team_member: team_member }
      let!(:fourth_membership) { Fabricate.build :membership, team: team }

      it 'invalidates equal membership' do
        expect(second_membership.valid?).to be false
        expect(second_membership.errors.full_messages).to eq ['Team member Um membro só pode ter uma participação por time.']
      end

      it { expect(first_membership.valid?).to be true }
      it { expect(third_membership.valid?).to be true }
      it { expect(fourth_membership.valid?).to be true }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team_member).with_prefix }
    it { is_expected.to delegate_method(:jira_account_id).to(:team_member) }
    it { is_expected.to delegate_method(:monthly_payment).to(:team_member) }
    it { is_expected.to delegate_method(:hours_per_month).to(:team_member) }
    it { is_expected.to delegate_method(:start_date).to(:team_member) }
    it { is_expected.to delegate_method(:end_date).to(:team_member) }
  end
end
