# frozen_string_literal: true

RSpec.describe ItemAssignment, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
    it { is_expected.to belong_to :membership }
    it { is_expected.to have_many(:item_assignment_notifications).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand }
    it { is_expected.to validate_presence_of :membership }

    context 'uniqueness' do
      let(:membership) { Fabricate :membership }
      let(:demand) { Fabricate :demand }
      let!(:start_time) { 1.day.ago }
      let!(:item_assignment) { Fabricate :item_assignment, demand: demand, membership: membership, start_time: start_time }
      let!(:same_item_assignment) { Fabricate.build :item_assignment, demand: demand, membership: membership, start_time: start_time }

      let!(:other_demand_assignment) { Fabricate.build :item_assignment, membership: membership, start_time: start_time }
      let!(:other_member_assignment) { Fabricate.build :item_assignment, demand: demand, start_time: start_time }
      let!(:other_date_item_assignment) { Fabricate.build :item_assignment, demand: demand, membership: membership, start_time: Time.zone.now }

      it 'returns the model invalid with errors on duplicated field' do
        expect(same_item_assignment).not_to be_valid
        expect(same_item_assignment.errors_on(:demand)).to eq [I18n.t('item_assignment.validations.demand_unique')]
      end

      it { expect(other_date_item_assignment).to be_valid }
      it { expect(other_demand_assignment).to be_valid }
      it { expect(other_member_assignment).to be_valid }
    end
  end

  context 'scopes' do
    describe '.for_dates' do
      before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

      after { travel_back }

      context 'with data' do
        let!(:first_item_assignment) { Fabricate :item_assignment, start_time: 10.days.ago, finish_time: 7.days.ago }
        let!(:second_item_assignment) { Fabricate :item_assignment, start_time: 9.days.ago, finish_time: 8.days.ago }
        let!(:third_item_assignment) { Fabricate :item_assignment, start_time: 4.days.ago, finish_time: 1.day.ago }
        let!(:fourth_item_assignment) { Fabricate :item_assignment, start_time: 4.days.ago, finish_time: nil }

        it { expect(described_class.for_dates(10.days.ago, 7.days.ago)).to match_array [first_item_assignment, second_item_assignment] }
        it { expect(described_class.for_dates(169.hours.ago, 6.days.ago)).to eq [first_item_assignment] }
        it { expect(described_class.for_dates(5.days.ago, 2.days.ago)).to eq [third_item_assignment, fourth_item_assignment] }
        it { expect(described_class.for_dates(9.days.ago, 6.days.ago)).to eq [first_item_assignment, second_item_assignment] }
        it { expect(described_class.for_dates(4.days.ago, nil)).to eq [third_item_assignment, fourth_item_assignment] }
      end

      context 'with no data' do
        it { expect(described_class.for_dates(7.days.ago, 6.days.ago)).to eq [] }
      end
    end

    describe '.not_for_membership' do
      let(:membership) { Fabricate :membership }
      let(:first_assignment) { Fabricate :item_assignment, membership: membership, finish_time: nil }
      let(:second_assignment) { Fabricate :item_assignment, membership: membership, finish_time: nil }
      let(:finished_assignment) { Fabricate :item_assignment, membership: membership, finish_time: Time.zone.now }
      let(:other_membership_assignment) { Fabricate :item_assignment, finish_time: nil }
      let(:second_other_membership_assignment) { Fabricate :item_assignment, finish_time: nil }

      it { expect(described_class.not_for_membership(membership)).to match_array [other_membership_assignment, second_other_membership_assignment] }
    end

    describe '.open_assignments' do
      let(:demand) { Fabricate :demand, end_date: nil }
      let(:finished_demand) { Fabricate :demand, end_date: Time.zone.now }

      let!(:first_assignment) { Fabricate :item_assignment, demand: demand, finish_time: nil }
      let!(:second_assignment) { Fabricate :item_assignment, demand: demand, finish_time: nil }
      let!(:third_assignment) { Fabricate :item_assignment, demand: finished_demand, finish_time: nil }
      let!(:discarded_assignment) { Fabricate :item_assignment, demand: demand, finish_time: nil, discarded_at: Time.zone.now }
      let!(:finished_assignment) { Fabricate :item_assignment, demand: demand, finish_time: Time.zone.now }

      it { expect(described_class.open_assignments).to match_array [first_assignment, second_assignment] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:team_member_name).to(:membership) }
  end

  describe '#working_hours_until' do
    before { travel_to Time.zone.local(2019, 8, 13, 10, 0, 0) }

    after { travel_back }

    let(:item_assignment) { Fabricate :item_assignment, start_time: 2.days.ago }
    let(:other_item_assignment) { Fabricate :item_assignment, start_time: 3.days.ago, finish_time: 1.day.ago }

    it { expect(item_assignment.working_hours_until).to eq 12 }
    it { expect(other_item_assignment.working_hours_until).to eq 6 }
  end

  describe '#stages_during_assignment' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, products: [product], team: team, company: company }

    let!(:analysis_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis }
    let!(:commitment_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'commitment_stage', commitment_point: true, end_point: false, queue: true, stage_type: :development }
    let!(:end_stage) { Fabricate :stage, company: company, projects: [project], teams: [team], name: 'end_stage', commitment_point: false, end_point: true, queue: false, stage_type: :development }

    let(:first_team_member) { Fabricate :team_member, company: company, name: 'first_member' }

    let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer }

    let(:first_demand) { Fabricate :demand, company: company, team: team, project: project }

    let!(:first_transition) { Fabricate :demand_transition, stage: commitment_stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: analysis_stage, demand: first_demand, last_time_in: 119.hours.ago, last_time_out: 105.hours.ago }

    let!(:first_assignment) { Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 11.days.ago, finish_time: 1.hour.ago }
    let!(:second_assignment) { Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 10.days.ago, finish_time: 5.days.ago }
    let!(:third_assignment) { Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 120.days.ago, finish_time: 40.days.ago }

    it { expect(first_assignment.stages_during_assignment).to match_array [analysis_stage, commitment_stage] }
    it { expect(second_assignment.stages_during_assignment).to eq [commitment_stage] }
    it { expect(third_assignment.stages_during_assignment).to eq [] }
  end

  context 'callbacks' do
    describe '#compute_assignment_effort' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let(:project) { Fabricate :project, products: [product], team: team, company: company }

      it 'computes the effort after saving' do
        travel_to Time.zone.local(2020, 6, 17, 10, 0, 0) do
          analysis_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis
          commitment_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'commitment_stage', commitment_point: true, end_point: false, queue: false, stage_type: :development
          Fabricate :stage, company: company, projects: [project], teams: [team], name: 'end_stage', commitment_point: false, end_point: true, queue: false, stage_type: :development

          first_team_member = Fabricate :team_member, company: company, name: 'first_member'
          second_team_member = Fabricate :team_member, company: company, name: 'second_member'

          first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer
          second_membership = Fabricate :membership, team: team, team_member: second_team_member, member_role: :developer

          first_demand = Fabricate :demand, company: company, team: team, project: project
          second_demand = Fabricate :demand, company: company, team: team, project: project

          Fabricate :demand_transition, stage: commitment_stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago
          Fabricate :demand_transition, stage: analysis_stage, demand: first_demand, last_time_in: 119.hours.ago, last_time_out: 105.hours.ago
          Fabricate :demand_transition, stage: analysis_stage, demand: second_demand, last_time_in: 11.days.ago, last_time_out: 4.days.ago

          first_assignment = Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 11.days.ago, finish_time: 1.hour.ago
          second_assignment = Fabricate :item_assignment, membership: second_membership, demand: second_demand, start_time: 10.days.ago, finish_time: 5.days.ago

          first_assignment.save
          expect(first_assignment.reload.item_assignment_effort).to eq 30
          expect(first_assignment.reload.assignment_for_role).to be true

          second_assignment.save
          expect(second_assignment.reload.item_assignment_effort).to eq 0
          expect(second_assignment.reload.assignment_for_role).to be false
        end
      end
    end

    describe '#compute_pull_interval' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let(:project) { Fabricate :project, products: [product], team: team, company: company }

      it 'computes the pull interval after saving' do
        travel_to Time.zone.local(2020, 6, 17, 10, 0, 0) do
          analysis_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis
          commitment_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'commitment_stage', commitment_point: true, end_point: false, queue: false, stage_type: :development
          Fabricate :stage, company: company, projects: [project], teams: [team], name: 'end_stage', commitment_point: false, end_point: true, queue: false, stage_type: :development

          first_team_member = Fabricate :team_member, company: company, name: 'first_member'
          second_team_member = Fabricate :team_member, company: company, name: 'second_member'

          first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer
          second_membership = Fabricate :membership, team: team, team_member: second_team_member, member_role: :developer

          first_demand = Fabricate :demand, company: company, team: team, project: project
          second_demand = Fabricate :demand, company: company, team: team, project: project

          Fabricate :demand_transition, stage: commitment_stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago
          Fabricate :demand_transition, stage: analysis_stage, demand: first_demand, last_time_in: 119.hours.ago, last_time_out: 105.hours.ago
          Fabricate :demand_transition, stage: analysis_stage, demand: second_demand, last_time_in: 11.days.ago, last_time_out: 4.days.ago

          first_assignment = Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 11.days.ago, finish_time: 1.week.ago
          second_assignment = Fabricate :item_assignment, membership: first_membership, demand: second_demand, start_time: 5.days.ago, finish_time: 1.hour.ago
          third_assignment = Fabricate :item_assignment, membership: second_membership, demand: second_demand, start_time: 10.days.ago, finish_time: 5.days.ago

          first_assignment.save
          expect(first_assignment.reload.pull_interval).to eq 0

          second_assignment.save
          expect(second_assignment.reload.pull_interval).to eq 172_800

          third_assignment.save
          expect(third_assignment.reload.pull_interval).to eq 0
        end
      end
    end

    describe '#notify_assignment' do
      it 'notify after saving' do
        expect(Slack::SlackNotificationService.instance).to receive(:notify_item_assigned)

        Fabricate :item_assignment
      end
    end
  end

  describe '#assigned_at' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, products: [product], team: team, company: company }

    it 'returns the stage where it was assigned at' do
      travel_to Time.zone.local(2020, 7, 22, 20, 0, 0) do
        analysis_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis

        first_team_member = Fabricate :team_member, company: company, name: 'first_member'

        first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer

        first_demand = Fabricate :demand, company: company, team: team, project: project
        second_demand = Fabricate :demand, company: company, team: team, project: project

        Fabricate :demand_transition, stage: analysis_stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago

        first_assignment = Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 9.days.ago, finish_time: 1.week.ago
        second_assignment = Fabricate :item_assignment, membership: first_membership, demand: second_demand, start_time: 3.days.ago, finish_time: 1.hour.ago

        expect(first_assignment.assigned_at).to eq analysis_stage

        expect(second_assignment.assigned_at).to be_nil
      end
    end
  end

  describe '#previous_assignment' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, products: [product], team: team, company: company }

    context 'with unpersisted assignment' do
      it 'returns the stage where it was assigned at' do
        first_team_member = Fabricate :team_member, company: company, name: 'first_member'
        first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer

        first_demand = Fabricate :demand, company: company, team: team, project: project
        second_demand = Fabricate :demand, company: company, team: team, project: project

        first_assignment = Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 9.days.ago, finish_time: nil
        second_assignment = Fabricate.build :item_assignment, membership: first_membership, demand: second_demand, start_time: 3.days.ago, finish_time: nil

        expect(second_assignment.previous_assignment).to eq first_assignment
      end
    end

    context 'with persisted assignment' do
      it 'returns the stage where it was assigned at' do
        first_team_member = Fabricate :team_member, company: company, name: 'first_member'
        first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer

        first_demand = Fabricate :demand, company: company, team: team, project: project
        second_demand = Fabricate :demand, company: company, team: team, project: project

        first_assignment = Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 9.days.ago, finish_time: nil
        second_assignment = Fabricate :item_assignment, membership: first_membership, demand: second_demand, start_time: 3.days.ago, finish_time: nil

        expect(second_assignment.previous_assignment).to eq first_assignment
      end
    end
  end

  describe '#membership_open_assignments' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, products: [product], team: team, company: company }

    it 'returns the open and kept assignments' do
      first_team_member = Fabricate :team_member, company: company, name: 'first_member'
      first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer

      first_demand = Fabricate :demand, company: company, team: team, project: project, end_date: nil
      second_demand = Fabricate :demand, company: company, team: team, project: project, end_date: nil
      third_demand = Fabricate :demand, company: company, team: team, project: project, end_date: nil
      fourth_demand = Fabricate :demand, company: company, team: team, project: project, end_date: Time.zone.now
      fifth_demand = Fabricate :demand, company: company, team: team, project: project, end_date: nil

      first_assignment = Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 9.days.ago, finish_time: nil
      second_assignment = Fabricate :item_assignment, membership: first_membership, demand: second_demand, start_time: 3.days.ago, finish_time: nil
      Fabricate :item_assignment, membership: first_membership, demand: third_demand, start_time: 3.days.ago, finish_time: Time.zone.now
      Fabricate :item_assignment, membership: first_membership, demand: fourth_demand, start_time: 3.days.ago, finish_time: nil
      Fabricate :item_assignment, membership: first_membership, demand: fifth_demand, start_time: 3.days.ago, finish_time: nil, discarded_at: Time.zone.now

      expect(first_assignment.membership_open_assignments).to match_array [first_assignment, second_assignment]
    end
  end
end
