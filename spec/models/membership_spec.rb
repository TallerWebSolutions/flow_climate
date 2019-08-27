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

  shared_context 'membership demands methods data' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:team_member) { Fabricate :team_member, company: company }
    let(:other_team_member) { Fabricate :team_member, company: company }
    let(:empty_team_member) { Fabricate :team_member, company: company }

    let(:first_demand) { Fabricate :demand, company: company, team: team, commitment_date: 2.days.ago, end_date: 1.day.ago }
    let(:second_demand) { Fabricate :demand, company: company, team: team, commitment_date: 3.days.ago, end_date: 2.days.ago }

    let!(:first_assignment) { Fabricate :item_assignment, team_member: team_member, demand: first_demand }
    let!(:second_assignment) { Fabricate :item_assignment, team_member: team_member, demand: second_demand }
    let!(:third_assignment) { Fabricate :item_assignment, team_member: other_team_member, demand: second_demand }

    let!(:first_block) { Fabricate :demand_block, blocker: team_member, demand: first_demand }
    let!(:second_block) { Fabricate :demand_block, blocker: team_member, demand: second_demand }

    let!(:first_comment) { Fabricate :demand_comment, team_member: team_member, demand: first_demand }
    let!(:second_comment) { Fabricate :demand_comment, team_member: team_member, demand: second_demand }

    let(:team_membership) { Fabricate :membership, team: team, team_member: team_member }
    let(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member }
    let(:empty_membership) { Fabricate :membership, team: team, team_member: empty_team_member }
  end

  describe '#demands' do
    include_context 'membership demands methods data'

    it { expect(team_membership.demands).to match_array [first_demand, second_demand] }
    it { expect(other_membership.demands).to eq [second_demand] }
    it { expect(empty_membership.demands).to eq [] }
  end

  describe '#demand_comments' do
    include_context 'membership demands methods data'

    it { expect(team_membership.demand_comments).to match_array [first_comment, second_comment] }
    it { expect(other_membership.demand_comments).to eq [] }
  end

  describe '#demand_blocks' do
    include_context 'membership demands methods data'

    it { expect(team_membership.demand_blocks).to match_array [first_block, second_block] }
    it { expect(other_membership.demand_blocks).to eq [] }
  end

  describe '#leadtime' do
    include_context 'membership demands methods data'

    it { expect(team_membership.leadtime).to be_within(0.1).of(86_400.0) }
    it { expect(other_membership.leadtime).to be_within(0.1).of(86_400.0) }
    it { expect(empty_membership.leadtime).to eq 0 }
  end

  describe '#pairing' do
    include_context 'membership demands methods data'

    it { expect(team_membership.pairing).to eq(other_team_member.name => 1) }
    it { expect(other_membership.pairing).to eq(team_member.name => 1) }
  end
end
