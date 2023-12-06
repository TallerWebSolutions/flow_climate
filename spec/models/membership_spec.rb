# frozen_string_literal: true

RSpec.describe Membership do
  context 'for enums' do
    it { is_expected.to define_enum_for(:member_role).with_values(developer: 0, manager: 1, client: 2, designer: 3) }
  end

  context 'for associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :team_member }
    it { is_expected.to have_many(:item_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:demands).through(:item_assignments) }
    it { is_expected.to have_many(:membership_available_hours_histories).dependent(:destroy) }
  end

  context 'for validations' do
    it { is_expected.to validate_presence_of :start_date }

    context 'unique active membership for team member' do
      it 'refuses duplicated members' do
        team = Fabricate :team
        team_member = Fabricate :team_member

        membership = Fabricate :membership, team: team, team_member: team_member, end_date: nil
        duplicated_membership = Fabricate.build :membership, team: team, team_member: team_member, end_date: nil
        second_valid_membership = Fabricate.build :membership, team_member: team_member, end_date: nil
        third_valid_membership = Fabricate.build :membership, team: team, end_date: nil
        fourth_valid_membership = Fabricate.build :membership, team_member: team_member, team: team, end_date: Time.zone.today
        expect(duplicated_membership).not_to be_valid
        expect(duplicated_membership.errors_on(:team_member)).to eq [I18n.t('activerecord.errors.models.membership.team_member.already_existent_active')]
        expect(membership).to be_valid
        expect(second_valid_membership).to be_valid
        expect(third_valid_membership).to be_valid
        expect(fourth_valid_membership).to be_valid
      end
    end
  end

  context 'for scopes' do
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

  context 'for delegations' do
    it { is_expected.to delegate_method(:name).to(:team_member).with_prefix }
    it { is_expected.to delegate_method(:jira_account_id).to(:team_member) }
    it { is_expected.to delegate_method(:company).to(:team) }
    it { is_expected.to delegate_method(:projects).to(:team_member) }
  end

  context 'for callbacks' do
    describe '#save_hours_history' do
      context 'if the hours changed' do
        it 'saves the history' do
          membership = Fabricate :membership, hours_per_month: 100

          membership.update(hours_per_month: 110, start_date: 2.days.ago)
          expect(History::MembershipAvailableHoursHistory.all.map(&:available_hours)).to eq [110]
        end
      end

      context 'if the hours did not change' do
        it 'does not save the history' do
          membership = Fabricate :membership, hours_per_month: 100

          membership.update(hours_per_month: 100, start_date: 2.days.ago)
          expect(History::MembershipAvailableHoursHistory.count).to eq 0
        end
      end
    end
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
    let(:product) { Fabricate :product, company: company, customer: customer }
    let(:project) { Fabricate :project, products: [product], team: team, company: company }

    let!(:analysis_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis }
    let(:commitment_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'commitment_stage', commitment_point: true, end_point: false, queue: false, stage_type: :development }
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

    it { expect(first_membership.pairing_count(Time.zone.today)).to eq(second_team_member.name => 2) }
    it { expect(second_membership.pairing_count(Time.zone.today)).to eq(first_team_member.name => 2) }
    it { expect(third_membership.pairing_count(Time.zone.today)).to eq({}) }
  end

  describe '#pairing_members' do
    include_context 'membership demands methods data'

    it { expect(first_membership.pairing_members(Time.zone.today)).to match_array [second_membership, second_membership] }
    it { expect(second_membership.pairing_members(Time.zone.today)).to match_array [first_membership, first_membership] }
    it { expect(third_membership.pairing_members(Time.zone.today)).to eq [] }
    it { expect(fourth_membership.pairing_members(Time.zone.today)).to eq [] }
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
      it { expect(first_membership.stages_to_work_on).to match_array [commitment_stage, end_stage] }
    end

    context 'when the member is not a developer' do
      it { expect(fourth_membership.stages_to_work_on).to match_array [analysis_stage, commitment_stage, end_stage] }
    end
  end

  describe '#to_hash' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, monthly_payment: 1200, end_date: nil }

    it 'returns the hash value' do
      membership = Fabricate :membership, team: team, team_member: team_member, hours_per_month: 100, start_date: 1.month.ago, end_date: nil

      expect(membership.to_hash).to eq(member_name: team_member.name, jira_account_id: team_member.jira_account_id)
    end
  end

  describe '#monthly_payment' do
    context 'with hours_per_month in the team member' do
      it 'returns the value share to the team' do
        team_member = Fabricate :team_member, hours_per_month: 160, monthly_payment: 100
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 80

        expect(membership.monthly_payment).to eq 50
      end
    end

    context 'with no hours_per_month in the team member' do
      it 'returns the total monthly payment' do
        team_member = Fabricate :team_member, hours_per_month: nil, monthly_payment: 100
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 80

        expect(membership.monthly_payment).to eq 100
      end
    end

    context 'with zero as hours_per_month in the team member' do
      it 'returns the total monthly payment' do
        team_member = Fabricate :team_member, hours_per_month: 0, monthly_payment: 100
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 0

        expect(membership.monthly_payment).to eq 100
      end
    end

    context 'with nil monthly payment in the team member' do
      it 'returns the total monthly payment' do
        team_member = Fabricate :team_member, hours_per_month: 160, monthly_payment: nil
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 0

        expect(membership.monthly_payment).to eq 0
      end
    end
  end

  describe '#effort_in_period' do
    context 'with efforts' do
      it 'returns the sum of efforts value in the period' do
        travel_to Time.zone.local(2023, 3, 23, 15) do
          first_demand = Fabricate :demand
          second_demand = Fabricate :demand
          third_demand = Fabricate :demand
          membership = Fabricate :membership

          first_assignment = Fabricate :item_assignment, demand: first_demand, membership: membership
          second_assignment = Fabricate :item_assignment, demand: second_demand, membership: membership
          third_assignment = Fabricate :item_assignment, demand: third_demand, membership: membership

          Fabricate :demand_effort, demand: first_demand, item_assignment: first_assignment, effort_value: 100, start_time_to_computation: 72.hours.ago, finish_time_to_computation: 70.hours.ago
          Fabricate :demand_effort, demand: second_demand, item_assignment: second_assignment, effort_value: 200, start_time_to_computation: 72.hours.ago, finish_time_to_computation: 70.hours.ago
          Fabricate :demand_effort, demand: third_demand, item_assignment: third_assignment, effort_value: 50, start_time_to_computation: 2.months.ago, finish_time_to_computation: 2.months.ago
          start_date = Time.zone.now.beginning_of_month
          end_date = Time.zone.now.end_of_month

          expect(membership.effort_in_period(start_date, end_date)).to eq 300
        end
      end
    end

    context 'without efforts' do
      it 'returns zero' do
        first_demand = Fabricate :demand
        second_demand = Fabricate :demand
        third_demand = Fabricate :demand
        membership = Fabricate :membership
        Fabricate :item_assignment, demand: first_demand, membership: membership
        Fabricate :item_assignment, demand: second_demand, membership: membership
        Fabricate :item_assignment, demand: third_demand, membership: membership

        start_date = Time.zone.now.beginning_of_month
        end_date = Time.zone.now.end_of_month

        expect(membership.effort_in_period(start_date, end_date)).to eq 0
      end
    end
  end

  describe '#realized_money_in_period' do
    context 'with efforts' do
      it 'returns the amount of money realized in the period' do
        travel_to Time.zone.local(2023, 3, 23, 15) do
          project = Fabricate :project, hour_value: 180
          other_project = Fabricate :project, hour_value: 163

          first_demand = Fabricate :demand, project: project
          second_demand = Fabricate :demand, project: other_project
          third_demand = Fabricate :demand, project: project
          membership = Fabricate :membership

          first_assignment = Fabricate :item_assignment, demand: first_demand, membership: membership
          second_assignment = Fabricate :item_assignment, demand: second_demand, membership: membership
          third_assignment = Fabricate :item_assignment, demand: third_demand, membership: membership

          Fabricate :demand_effort, demand: first_demand, item_assignment: first_assignment, effort_value: 100, start_time_to_computation: 72.hours.ago, finish_time_to_computation: 70.hours.ago
          Fabricate :demand_effort, demand: second_demand, item_assignment: second_assignment, effort_value: 200, start_time_to_computation: 72.hours.ago, finish_time_to_computation: 70.hours.ago
          Fabricate :demand_effort, demand: third_demand, item_assignment: third_assignment, effort_value: 50, start_time_to_computation: 2.months.ago, finish_time_to_computation: 2.months.ago
          start_date = Time.zone.now.beginning_of_month
          end_date = Time.zone.now.end_of_month

          expect(membership.realized_money_in_period(start_date, end_date).to_f).to eq 50_600
        end
      end
    end

    context 'without efforts' do
      it 'returns zero' do
        first_demand = Fabricate :demand
        second_demand = Fabricate :demand
        third_demand = Fabricate :demand
        membership = Fabricate :membership
        Fabricate :item_assignment, demand: first_demand, membership: membership
        Fabricate :item_assignment, demand: second_demand, membership: membership
        Fabricate :item_assignment, demand: third_demand, membership: membership

        start_date = Time.zone.now.beginning_of_month
        end_date = Time.zone.now.end_of_month

        expect(membership.effort_in_period(start_date, end_date)).to eq 0
      end
    end
  end

  describe '#cards_count' do
    context 'with efforts' do
      it 'returns the amount of cards in the efforts' do
        travel_to Time.zone.local(2023, 4, 13, 10) do
          start_date = Time.zone.today.beginning_of_month.to_date
          end_date = start_date.end_of_month

          team = Fabricate :team
          demand = Fabricate :demand, team: team
          other_demand = Fabricate :demand, team: team
          membership = Fabricate :membership, team: team
          assignment = Fabricate :item_assignment, membership: membership, demand: demand
          other_assignment = Fabricate :item_assignment, membership: membership, demand: other_demand
          Fabricate :demand_effort, demand: demand, item_assignment: assignment, start_time_to_computation: 1.day.ago, finish_time_to_computation: Time.zone.now
          Fabricate :demand_effort, demand: other_demand, item_assignment: other_assignment, start_time_to_computation: 1.day.ago, finish_time_to_computation: Time.zone.now

          expect(membership.cards_count(start_date, end_date)).to eq 2
        end
      end
    end

    context 'without efforts' do
      it 'returns zero' do
        travel_to Time.zone.local(2023, 4, 13, 10) do
          start_date = Time.zone.today.beginning_of_month.to_date
          end_date = start_date.end_of_month

          team = Fabricate :team
          membership = Fabricate :membership, team: team

          expect(membership.cards_count(start_date, end_date)).to eq 0
        end
      end
    end
  end

  describe '#avg_hours_per_demand' do
    context 'with efforts' do
      it 'returns the amount of cards in the efforts' do
        travel_to Time.zone.local(2023, 4, 13, 10) do
          start_date = Time.zone.today.beginning_of_month.to_date
          end_date = start_date.end_of_month

          team = Fabricate :team
          demand = Fabricate :demand, team: team
          other_demand = Fabricate :demand, team: team
          membership = Fabricate :membership, team: team
          assignment = Fabricate :item_assignment, membership: membership, demand: demand
          other_assignment = Fabricate :item_assignment, membership: membership, demand: other_demand
          Fabricate :demand_effort, demand: demand, item_assignment: assignment, start_time_to_computation: 1.day.ago, finish_time_to_computation: Time.zone.now, effort_value: 100
          Fabricate :demand_effort, demand: other_demand, item_assignment: other_assignment, start_time_to_computation: 1.day.ago, finish_time_to_computation: Time.zone.now, effort_value: 100

          expect(membership.avg_hours_per_demand(start_date, end_date).to_f).to eq 100
        end
      end
    end

    context 'without efforts' do
      it 'returns zero' do
        travel_to Time.zone.local(2023, 4, 13, 10) do
          start_date = Time.zone.today.beginning_of_month.to_date
          end_date = start_date.end_of_month

          team = Fabricate :team
          membership = Fabricate :membership, team: team

          expect(membership.avg_hours_per_demand(start_date, end_date)).to eq 0
        end
      end
    end
  end

  describe '#realized_hour_value' do
    context 'with efforts' do
      it 'returns the realized effort' do
        travel_to Time.zone.local(2023, 4, 13, 10) do
          start_date = Time.zone.today.beginning_of_month.to_date
          end_date = start_date.end_of_month

          team = Fabricate :team
          demand = Fabricate :demand, team: team
          other_demand = Fabricate :demand, team: team
          team_member = Fabricate :team_member, monthly_payment: 7000, hours_per_month: 160
          membership = Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120
          assignment = Fabricate :item_assignment, membership: membership, demand: demand
          other_assignment = Fabricate :item_assignment, membership: membership, demand: other_demand
          Fabricate :demand_effort, demand: demand, item_assignment: assignment, start_time_to_computation: 1.day.ago, finish_time_to_computation: Time.zone.now, effort_value: 100
          Fabricate :demand_effort, demand: other_demand, item_assignment: other_assignment, start_time_to_computation: 1.day.ago, finish_time_to_computation: Time.zone.now, effort_value: 100

          expect(membership.realized_hour_value(end_date).to_f).to eq 26.25
        end
      end
    end

    context 'without efforts' do
      it 'returns zero' do
        travel_to Time.zone.local(2023, 4, 13, 10) do
          start_date = Time.zone.today.beginning_of_month.to_date
          end_date = start_date.end_of_month

          team = Fabricate :team
          membership = Fabricate :membership, team: team

          expect(membership.realized_hour_value(end_date)).to eq 0
        end
      end
    end
  end

  describe '#expected_hour_value' do
    context 'with hours per month' do
      it 'returns the monthly payment divided by the hours per month' do
        team_member = Fabricate :team_member, hours_per_month: 160, monthly_payment: 10_000
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 100

        expect(membership.expected_hour_value).to eq 62.5
      end
    end

    context 'without hours per month' do
      it 'returns zero' do
        team_member = Fabricate :team_member, hours_per_month: 160, monthly_payment: 10_000
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 0

        expect(membership.expected_hour_value).to eq 0
      end
    end

    context 'with histories' do
      it 'returns based on the history' do
        team_member = Fabricate :team_member, hours_per_month: 128, monthly_payment: 10_000
        membership = Fabricate :membership, team_member: team_member, hours_per_month: 200
        Fabricate :membership_available_hours_history, membership: membership, change_date: 3.months.ago, available_hours: 160
        Fabricate :membership_available_hours_history, membership: membership, change_date: 2.months.ago, available_hours: 90

        expect(membership.expected_hour_value(1.month.ago)).to eq 78.125
      end
    end
  end

  describe '#current_hours_per_month' do
    context 'without histories' do
      it 'returns the value in the membership' do
        membership = Fabricate :membership, hours_per_month: 100

        expect(membership.current_hours_per_month).to eq 100
      end
    end

    context 'with histories' do
      context 'without date' do
        it 'returns the value in the last history' do
          membership = Fabricate :membership, hours_per_month: 100
          Fabricate :membership_available_hours_history, membership: membership, change_date: 3.months.ago, available_hours: 160
          Fabricate :membership_available_hours_history, membership: membership, change_date: 2.months.ago, available_hours: 90

          expect(membership.current_hours_per_month).to eq 90
        end
      end

      context 'with date' do
        it 'returns the value in the last history' do
          membership = Fabricate :membership, hours_per_month: 100
          Fabricate :membership_available_hours_history, membership: membership, change_date: 3.months.ago, available_hours: 160
          Fabricate :membership_available_hours_history, membership: membership, change_date: 2.months.ago, available_hours: 90

          expect(membership.current_hours_per_month(65.days.ago)).to eq 160
        end
      end
    end
  end
end
