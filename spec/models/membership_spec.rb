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

    context 'unique active membership for team member' do
      let(:team) { Fabricate :team }
      let(:team_member) { Fabricate :team_member }
      let(:other_team_member) { Fabricate :team_member }

      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, end_date: nil }
      let!(:duplicated_membership) { Fabricate.build :membership, team: team, team_member: team_member, end_date: nil }
      let!(:second_valid_membership) { Fabricate.build :membership, team_member: team_member, end_date: nil }
      let!(:third_valid_membership) { Fabricate.build :membership, team: team, end_date: nil }

      before { duplicated_membership.valid? }

      it { expect(membership.valid?).to be true }
      it { expect(second_valid_membership.valid?).to be true }
      it { expect(third_valid_membership.valid?).to be true }

      it { expect(duplicated_membership.errors_on(:team_member)).to eq [I18n.t('activerecord.errors.models.membership.team_member.already_existent_active')] }
    end
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

  shared_context 'membership demands methods data' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:first_team_member) { Fabricate :team_member, company: company, name: 'first_member' }
    let(:second_team_member) { Fabricate :team_member, company: company, name: 'second_member' }
    let(:third_team_member) { Fabricate :team_member, company: company, name: 'third_member' }
    let(:fourth_team_member) { Fabricate :team_member, company: company, name: 'fourth_member' }
    let(:fifth_team_member) { Fabricate :team_member, company: company, name: 'fifth_member' }

    let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer }
    let!(:second_membership) { Fabricate :membership, team: team, team_member: second_team_member, member_role: :developer }

    let!(:third_membership) { Fabricate :membership, team: team, team_member: third_team_member, member_role: :developer }
    let!(:fourth_membership) { Fabricate :membership, team: team, team_member: fourth_team_member, member_role: :client }
    let!(:fifth_membership) { Fabricate :membership, team: team, team_member: fifth_team_member, member_role: :developer }

    let(:first_demand) { Fabricate :demand, company: company, team: team, commitment_date: 2.days.ago, end_date: 1.day.ago }
    let(:second_demand) { Fabricate :demand, company: company, team: team, commitment_date: 3.days.ago, end_date: 2.days.ago }
    let(:third_demand) { Fabricate :demand, company: company, team: team, commitment_date: 3.days.ago, end_date: 2.days.ago }

    let!(:first_assignment) { Fabricate :item_assignment, team_member: first_team_member, demand: first_demand }
    let!(:second_assignment) { Fabricate :item_assignment, team_member: first_team_member, demand: second_demand }
    let!(:third_assignment) { Fabricate :item_assignment, team_member: second_team_member, demand: first_demand }
    let!(:fourth_assignment) { Fabricate :item_assignment, team_member: second_team_member, demand: second_demand }
    let!(:fifth_assignment) { Fabricate :item_assignment, team_member: fourth_team_member, demand: first_demand }
    let!(:sixth_assignment) { Fabricate :item_assignment, team_member: fifth_team_member, demand: third_demand }

    let!(:first_block) { Fabricate :demand_block, blocker: first_team_member, demand: first_demand }
    let!(:second_block) { Fabricate :demand_block, blocker: first_team_member, demand: second_demand }

    let!(:first_comment) { Fabricate :demand_comment, team_member: first_team_member, demand: first_demand }
    let!(:second_comment) { Fabricate :demand_comment, team_member: first_team_member, demand: second_demand }
  end

  describe '#demands' do
    include_context 'membership demands methods data'

    it { expect(first_membership.demands).to match_array [first_demand, second_demand] }
    it { expect(second_membership.demands).to match_array [first_demand, second_demand] }
    it { expect(third_membership.demands).to eq [] }
  end

  describe '#demand_comments' do
    include_context 'membership demands methods data'

    it { expect(first_membership.demand_comments).to match_array [first_comment, second_comment] }
    it { expect(second_membership.demand_comments).to eq [] }
    it { expect(third_membership.demand_comments).to eq [] }
  end

  describe '#demand_blocks' do
    include_context 'membership demands methods data'

    it { expect(first_membership.demand_blocks).to match_array [first_block, second_block] }
    it { expect(second_membership.demand_blocks).to eq [] }
    it { expect(third_membership.demand_blocks).to eq [] }
  end

  describe '#leadtime' do
    include_context 'membership demands methods data'

    it { expect(first_membership.leadtime).to be_within(0.1).of(86_400.0) }
    it { expect(second_membership.leadtime).to be_within(0.1).of(86_400.0) }
    it { expect(third_membership.leadtime).to eq 0 }
  end

  describe '#pairing_count' do
    include_context 'membership demands methods data'

    it { expect(first_membership.pairing_count).to eq(second_team_member.name => 2) }
    it { expect(second_membership.pairing_count).to eq(first_team_member.name => 2) }
    it { expect(third_membership.pairing_count).to eq({}) }
  end

  describe '#pairing_members' do
    include_context 'membership demands methods data'

    it { expect(first_membership.pairing_members).to eq [second_team_member.name, second_team_member.name] }
    it { expect(second_membership.pairing_members).to eq [first_team_member.name, first_team_member.name] }
    it { expect(third_membership.pairing_members).to eq [] }
  end
end
