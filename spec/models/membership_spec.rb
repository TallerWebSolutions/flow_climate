# frozen_string_literal: true

RSpec.describe Membership, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:member_role).with_values(developer: 0, manager: 1, client: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :team_member }
    it { is_expected.to have_many(:item_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:demands).through(:item_assignments) }
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
      let!(:fourth_valid_membership) { Fabricate.build :membership, team_member: team_member, team: team, end_date: Time.zone.today }

      before { duplicated_membership.valid? }

      it { expect(membership.valid?).to be true }
      it { expect(second_valid_membership.valid?).to be true }
      it { expect(third_valid_membership.valid?).to be true }
      it { expect(fourth_valid_membership.valid?).to be true }

      it { expect(duplicated_membership.errors_on(:team_member)).to eq [I18n.t('activerecord.errors.models.membership.team_member.already_existent_active')] }
    end
  end

  context 'scopes' do
    let!(:active) { Fabricate :membership, end_date: nil }
    let!(:other_active) { Fabricate :membership, end_date: nil }
    let!(:inactive) { Fabricate :membership, end_date: Time.zone.today }

    describe '.active' do
      it { expect(described_class.active).to match_array [active, other_active] }
    end

    describe '.inactive' do
      it { expect(described_class.inactive).to eq [inactive] }
    end

    describe '.active_for_date' do
      it { expect(described_class.active_for_date(Time.zone.yesterday)).to match_array [active, other_active, inactive] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:team_member).with_prefix }
    it { is_expected.to delegate_method(:jira_account_id).to(:team_member) }
    it { is_expected.to delegate_method(:monthly_payment).to(:team_member) }
    it { is_expected.to delegate_method(:company).to(:team) }
    it { is_expected.to delegate_method(:projects).to(:team_member) }
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

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, products: [product], team: team, company: company }

    let!(:analysis_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis }
    let(:commitment_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'commitment_stage', commitment_point: true, end_point: false, queue: true, stage_type: :development }
    let(:end_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'end_stage', commitment_point: false, end_point: true, queue: false, stage_type: :development }

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

    let(:first_demand) { Fabricate :demand, company: company, team: team, project: project }
    let(:second_demand) { Fabricate :demand, company: company, team: team, project: project }
    let(:third_demand) { Fabricate :demand, company: company, team: team, project: project }

    let!(:first_transition) { Fabricate :demand_transition, stage: commitment_stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: commitment_stage, demand: second_demand, last_time_in: 6.days.ago, last_time_out: 4.days.ago }
    let!(:third_transition) { Fabricate :demand_transition, stage: commitment_stage, demand: third_demand, last_time_in: 96.hours.ago, last_time_out: 95.hours.ago }

    let!(:fourth_transition) { Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: 5.days.ago, last_time_out: 1.minute.ago }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: 4.days.ago, last_time_out: 2.days.ago }
    let!(:sixth_transition) { Fabricate :demand_transition, stage: end_stage, demand: third_demand, last_time_in: 95.hours.ago, last_time_out: 94.hours.ago }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: analysis_stage, demand: first_demand, last_time_in: 120.hours.ago, last_time_out: 105.hours.ago }

    let!(:first_assignment) { Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 4.days.ago, finish_time: 1.day.ago }
    let!(:second_assignment) { Fabricate :item_assignment, membership: first_membership, demand: second_demand, start_time: 3.days.ago, finish_time: 1.day.ago }
    let!(:third_assignment) { Fabricate :item_assignment, membership: second_membership, demand: first_demand, start_time: 4.days.ago, finish_time: 1.day.ago }
    let!(:fourth_assignment) { Fabricate :item_assignment, membership: second_membership, demand: second_demand, start_time: 3.days.ago, finish_time: 1.day.ago }
    let!(:fifth_assignment) { Fabricate :item_assignment, membership: fourth_membership, demand: first_demand, start_time: 120.hours.ago, finish_time: 105.hours.ago }
    let!(:sixth_assignment) { Fabricate :item_assignment, membership: fifth_membership, demand: third_demand, start_time: 4.days.ago, finish_time: 1.day.ago }

    let!(:first_block) { Fabricate :demand_block, blocker: first_team_member, demand: first_demand }
    let!(:second_block) { Fabricate :demand_block, blocker: first_team_member, demand: second_demand }

    let!(:first_comment) { Fabricate :demand_comment, team_member: first_team_member, demand: first_demand }
    let!(:second_comment) { Fabricate :demand_comment, team_member: first_team_member, demand: second_demand }
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

  describe '#pairing_count' do
    include_context 'membership demands methods data'

    it { expect(first_membership.pairing_count).to eq(second_team_member.name => 2) }
    it { expect(second_membership.pairing_count).to eq(first_team_member.name => 2) }
    it { expect(third_membership.pairing_count).to eq({}) }
  end

  describe '#pairing_members' do
    include_context 'membership demands methods data'

    it { expect(first_membership.pairing_members).to match_array [second_membership, second_membership] }
    it { expect(second_membership.pairing_members).to match_array [first_membership, first_membership] }
    it { expect(third_membership.pairing_members).to eq [] }
    it { expect(fourth_membership.pairing_members).to eq [] }
  end

  describe '#demands_ids' do
    include_context 'membership demands methods data'

    context 'when the member is a developer' do
      it { expect(first_membership.demands_ids).to match_array [first_demand.id, second_demand.id] }
    end
  end

  describe '#demands_for_role' do
    include_context 'membership demands methods data'

    context 'when the member is a developer' do
      it { expect(first_membership.demands_for_role).to match_array [first_demand, second_demand] }
    end

    context 'when the member is not a developer' do
      it { expect(fourth_membership.demands_for_role).to match_array [first_demand] }
    end
  end

  describe '#stages_to_work_on' do
    include_context 'membership demands methods data'

    context 'when the member is a developer' do
      it { expect(first_membership.stages_to_work_on).to match_array [end_stage] }
    end

    context 'when the member is not a developer' do
      it { expect(fourth_membership.stages_to_work_on).to match_array [analysis_stage, commitment_stage, end_stage] }
    end
  end
end
