# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:artifact_type).with_values(story: 0, epic: 1, theme: 2) }
    it { is_expected.to define_enum_for(:demand_type).with_values(feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5) }
    it { is_expected.to define_enum_for(:class_of_service).with_values(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :portfolio_unit }
    it { is_expected.to belong_to(:parent).class_name('Demand').inverse_of(:children) }
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :risk_review }

    it { is_expected.to have_many(:children).class_name('Demand').inverse_of(:parent).dependent(:destroy) }
    it { is_expected.to have_many(:demand_transitions).dependent(:destroy) }
    it { is_expected.to have_many(:demand_blocks).dependent(:destroy) }
    it { is_expected.to have_many(:demand_comments).dependent(:destroy) }
    it { is_expected.to have_many(:flow_impacts).dependent(:destroy) }
    it { is_expected.to have_many(:stages).through(:demand_transitions) }

    it { is_expected.to have_many(:item_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:team_members).through(:item_assignments) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :team }
      it { is_expected.to validate_presence_of :demand_id }
      it { is_expected.to validate_presence_of :created_date }
      it { is_expected.to validate_presence_of :demand_type }
      it { is_expected.to validate_presence_of :class_of_service }
    end

    context 'complex ones' do
      context 'demand_id uniqueness' do
        let!(:project) { Fabricate :project }
        let!(:demand) { Fabricate :demand, project: project, company: project.company, demand_id: 'zzz' }

        context 'same demand_id in same project' do
          let!(:other_demand) { Fabricate.build :demand, project: project, company: project.company, demand_id: 'zzz' }

          it 'does not accept the model' do
            expect(other_demand.valid?).to be false
            expect(other_demand.errors[:demand_id]).to eq [I18n.t('demand.validations.demand_id_unique.message')]
          end
        end

        context 'different demand_id in same customer' do
          let!(:other_demand) { Fabricate.build :demand, project: project, demand_id: 'aaa' }

          it { expect(other_demand.valid?).to be true }
        end

        context 'same demand_id in different project' do
          let!(:other_demand) { Fabricate.build :demand, demand_id: 'zzz' }

          it { expect(other_demand.valid?).to be true }
        end
      end
    end
  end

  context 'scopes' do
    let(:project) { Fabricate :project }
    let!(:first_epic) { Fabricate :demand, project: project, artifact_type: :epic }

    describe '.opened_after_date' do
      let!(:first_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-02 11:00') }
      let!(:second_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:third_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-05 11:00') }

      it { expect(described_class.opened_after_date(Date.new(2018, 2, 3))).to match_array [second_demand, third_demand] }
    end

    describe '.finished' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: nil }

      it { expect(described_class.finished).to match_array [first_demand, second_demand] }
    end

    describe '.finished_with_leadtime' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.now, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.now, leadtime: 3 }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: Time.zone.now }

      it { expect(described_class.finished_with_leadtime).to match_array [first_demand, second_demand] }
    end

    describe '.finished_until_date' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: 2.days.ago, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: 1.day.ago, leadtime: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(described_class.finished_until_date(1.day.ago)).to match_array [first_demand, second_demand] }
    end

    describe '.finished_after_date' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: 2.days.ago, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: 1.day.ago, leadtime: 3 }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(described_class.finished_after_date(1.day.ago)).to match_array [second_demand, third_demand] }
    end

    describe '.not_finished' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(described_class.not_finished).to match_array [first_demand, second_demand] }
    end

    describe '.finished_in_month' do
      before { travel_to Date.new(2018, 10, 23) }

      after { travel_back }

      let(:first_demand) { Fabricate :demand, end_date: 2.months.ago }
      let(:second_demand) { Fabricate :demand, end_date: 1.month.ago }
      let(:third_demand) { Fabricate :demand, end_date: 1.month.ago }
      let(:fourth_demand) { Fabricate :demand, end_date: Time.zone.today }

      it { expect(described_class.finished_in_month(2.months.ago.to_date.month, 2.months.ago.to_date.year)).to eq [first_demand] }
      it { expect(described_class.finished_in_month(1.month.ago.to_date.month, 1.month.ago.to_date.year)).to match_array [second_demand, third_demand] }
      it { expect(described_class.finished_in_month(Time.zone.today.to_date.month, Time.zone.today.to_date.year)).to eq [fourth_demand] }
    end

    describe '.finished_in_week' do
      before { travel_to Date.new(2018, 10, 23) }

      after { travel_back }

      let(:first_demand) { Fabricate :demand, end_date: 2.weeks.ago }
      let(:second_demand) { Fabricate :demand, end_date: 1.week.ago }
      let(:third_demand) { Fabricate :demand, end_date: 1.week.ago }
      let(:fourth_demand) { Fabricate :demand, end_date: Time.zone.today }

      it { expect(described_class.finished_in_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to eq [first_demand] }
      it { expect(described_class.finished_in_week(1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [second_demand, third_demand] }
      it { expect(described_class.finished_in_week(Time.zone.today.to_date.cweek, Time.zone.today.to_date.cwyear)).to eq [fourth_demand] }
    end

    describe '.in_wip' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil }

      it { expect(described_class.in_wip.map(&:id)).to match_array [second_demand.id, third_demand.id] }
    end

    describe '.to_dates' do
      let!(:first_demand) { Fabricate :demand, created_date: 3.months.ago, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, created_date: 1.month.ago, end_date: 15.days.ago }
      let!(:third_demand) { Fabricate :demand, created_date: 2.months.ago, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, created_date: 4.months.ago, end_date: 1.day.from_now }

      it { expect(described_class.to_dates(1.month.ago, Time.zone.now).map(&:id)).to match_array [second_demand.id, third_demand.id, first_epic.id] }
    end

    describe '.to_end_dates' do
      let!(:first_demand) { Fabricate :demand, created_date: 3.months.ago, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, created_date: 1.month.ago, end_date: 15.days.ago }
      let!(:third_demand) { Fabricate :demand, created_date: 2.months.ago, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, created_date: 4.months.ago, end_date: 1.day.from_now }

      let!(:fifth_demand) { Fabricate :demand, created_date: 1.month.ago, end_date: nil }

      it { expect(described_class.to_end_dates(1.month.ago, Time.zone.now).map(&:id)).to match_array [second_demand.id, third_demand.id, first_epic.id] }
    end

    describe '.finished_in_downstream' do
      let!(:first_demand) { Fabricate :demand, commitment_date: 3.months.ago, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, commitment_date: 1.month.ago, end_date: 15.days.ago }
      let!(:third_demand) { Fabricate :demand, commitment_date: nil, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, commitment_date: nil, end_date: 1.day.from_now }

      it { expect(described_class.finished_in_downstream.map(&:id)).to match_array [first_demand.id, second_demand.id] }
    end

    describe '.finished_in_upstream' do
      let!(:first_demand) { Fabricate :demand, commitment_date: 3.months.ago, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, commitment_date: 1.month.ago, end_date: 15.days.ago }
      let!(:third_demand) { Fabricate :demand, commitment_date: nil, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, commitment_date: nil, end_date: 1.day.from_now }

      it { expect(described_class.finished_in_upstream.map(&:id)).to match_array [third_demand.id, fourth_demand.id] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:project).with_prefix }
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
    it { is_expected.to delegate_method(:name).to(:portfolio_unit).with_prefix }
  end

  context 'soft deletion' do
    let(:demand) { Fabricate :demand }
    let!(:demand_transtion) { Fabricate :demand_transition, demand: demand }
    let!(:other_demand_transtion) { Fabricate :demand_transition, demand: demand }
    let!(:demand_block) { Fabricate :demand_block, demand: demand }
    let!(:other_demand_block) { Fabricate :demand_block, demand: demand }

    describe '#discard' do
      it 'also discards the transitions' do
        demand.discard
        expect(demand.reload.discarded_at).not_to be_nil
        expect(demand_transtion.reload.discarded_at).not_to be_nil
        expect(other_demand_transtion.reload.discarded_at).not_to be_nil

        expect(demand_block.reload.discarded_at).not_to be_nil
        expect(other_demand_block.reload.discarded_at).not_to be_nil
      end
    end

    describe '#undiscard' do
      before { demand.discard }

      it 'also undiscards the transitions' do
        demand.undiscard
        expect(demand.reload.discarded_at).to be_nil

        expect(demand_transtion.reload.discarded_at).to be_nil
        expect(other_demand_transtion.reload.discarded_at).to be_nil

        expect(demand_block.reload.discarded_at).to be_nil
        expect(other_demand_block.reload.discarded_at).to be_nil
      end
    end
  end

  describe '#update_effort!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:team) { Fabricate :team, company: company }

    let(:team_member) { Fabricate :team_member, company: company }
    let(:other_team_member) { Fabricate :team_member, company: company }
    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
    let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }

    let(:project) { Fabricate :project, customers: [customer], percentage_effort_to_bugs: 20 }
    let(:upstream_effort_stage) { Fabricate :stage, stage_stream: :upstream }
    let(:downstream_effort_stage) { Fabricate :stage, stage_stream: :downstream }

    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: upstream_effort_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: project, stage: downstream_effort_stage, compute_effort: true, pairing_percentage: 20, stage_percentage: 90, management_percentage: 15 }

    context 'having only one assined' do
      context 'having no blockings' do
        let(:demand) { Fabricate :demand, project: project }
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:downstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:00'), last_time_out: Time.zone.parse('2018-03-06 15:00') }
        let!(:discarded_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:00'), last_time_out: Time.zone.parse('2018-03-06 15:00'), discarded_at: Time.zone.now }

        let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: nil }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 6.6
          expect(demand.effort_downstream.to_f).to eq 2.07
        end
      end

      context 'having blockings' do
        let(:demand) { Fabricate :demand, project: project }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-07 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: Time.zone.parse('2018-03-06 00:00') }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00') }
        let!(:third_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2018-03-06 10:00') }
        let!(:out_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }
        let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00'), discarded_at: Time.zone.now }

        let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: nil }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 8.8
          expect(demand.effort_downstream.to_f).to eq 0.0
        end
      end

      context 'having no transition in the effort stage' do
        let(:demand) { Fabricate :demand, project: project, effort_upstream: 0, effort_downstream: 0 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        it 'does not change the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 0.0
          expect(demand.effort_downstream.to_f).to eq 0.0
        end
      end
    end

    context 'having a pair assigned' do
      let(:demand) { Fabricate :demand, project: project, effort_upstream: 0, effort_downstream: 0 }

      context 'having no blockings' do
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:downstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:01'), last_time_out: Time.zone.parse('2018-03-06 15:00') }

        let!(:upstream_item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: Time.zone.parse('2018-03-06 13:00') }
        let!(:other_upstream_item_assignment) { Fabricate :item_assignment, demand: demand, team_member: other_team_member, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: Time.zone.parse('2018-03-06 13:00') }

        let!(:downstream_item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.parse('2018-03-06 13:00'), finish_time: nil }
        let!(:other_downstream_item_assignment) { Fabricate :item_assignment, demand: demand, team_member: other_team_member, start_time: Time.zone.parse('2018-03-06 13:00'), finish_time: nil }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 13.86
          expect(demand.effort_downstream.to_f).to eq 4.945
        end
      end

      context 'having blockings' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-08 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 05:00') }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 11:00') }
        let!(:out_demand_block) { Fabricate :demand_block, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }
        let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00'), discarded_at: Time.zone.now }

        let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: nil }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 12.1
          expect(demand.effort_downstream.to_f).to eq 0.0
        end
      end

      context 'having no transition in the effort stage' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        it 'does not change the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 0.0
          expect(demand.effort_downstream.to_f).to eq 0.0
        end
      end

      context 'when the demand has manual effort' do
        let(:demand) { Fabricate :demand, project: project, effort_upstream: 30, effort_downstream: 23, manual_effort: true }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        it 'does not change the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 30.0
          expect(demand.effort_downstream.to_f).to eq 23.0
        end
      end

      context 'when the demand is a bug' do
        let(:demand) { Fabricate :demand, project: project, demand_type: :bug, effort_upstream: 30, effort_downstream: 23, manual_effort: false }
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-20 13:00') }
        let!(:downstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:00'), last_time_out: Time.zone.parse('2018-03-14 15:00') }

        let!(:item_assignment) { Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: nil }

        it 'changes the effort based on the bug configuration' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 14.52
          expect(demand.effort_downstream.to_f).to eq 7.866
        end
      end
    end
  end

  context 'computed fields' do
    context 'leadtime' do
      context 'having commitment and end dates' do
        let!(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: 1.hour.ago }

        it { expect(demand.leadtime.to_f).to be_within(1.second).of(169_200.001) }
      end

      context 'having no commitment date but having end date' do
        let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: 1.hour.ago }

        it { expect(demand.leadtime).to eq nil }
      end

      context 'having commitment date but no end date' do
        let(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: nil }

        it { expect(demand.leadtime).to eq nil }
      end
    end
  end

  describe '#blocked_working_time_upstream' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customers: [customer] }
    let(:effort_stage) { Fabricate :stage, stage_stream: :upstream }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: effort_stage, compute_effort: true }
    let(:demand) { Fabricate :demand, project: project }

    context 'having no blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.blocked_working_time_upstream.to_f).to eq 0.0 }
    end

    context 'having blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
      let!(:first_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:second_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:third_demand_block) { Fabricate :demand_block, demand: demand, active: false, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:out_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00'), discarded_at: Time.zone.now }

      it { expect(demand.blocked_working_time_upstream.to_f).to eq 9.0 }
    end
  end

  describe '#blocked_working_time_downstream' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customers: [customer] }
    let(:effort_stage) { Fabricate :stage, stage_stream: :downstream }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: effort_stage, compute_effort: true }
    let(:demand) { Fabricate :demand, project: project }

    context 'having no blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.blocked_working_time_downstream.to_f).to eq 0.0 }
    end

    context 'having blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
      let!(:first_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:second_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:third_demand_block) { Fabricate :demand_block, demand: demand, active: false, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:out_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }
      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00'), discarded_at: Time.zone.now }

      it { expect(demand.blocked_working_time_downstream.to_f).to eq 9.0 }
    end
  end

  describe '#downstream_demand?' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customers: [customer] }
    let(:downstream_stage) { Fabricate :stage, stage_stream: :downstream }
    let(:upstream_stage) { Fabricate :stage, stage_stream: :upstream }

    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: upstream_stage }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: project, stage: downstream_stage }

    context 'having commitment_date' do
      let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }

      it { expect(demand.downstream_demand?).to be true }
    end

    context 'having no commitment_date' do
      let(:demand) { Fabricate :demand, project: project, commitment_date: nil }

      it { expect(demand.downstream_demand?).to be false }
    end
  end

  describe '#total_effort' do
    let(:demand) { Fabricate :demand, effort_upstream: 10, effort_downstream: 20 }

    it { expect(demand.total_effort).to eq 30 }
  end

  describe '#current_stage' do
    context 'having transitions' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customers: [customer] }
      let(:stage) { Fabricate :stage, company: company, projects: [project] }
      let(:other_stage) { Fabricate :stage, company: company, projects: [project] }

      let(:demand) { Fabricate :demand, project: project }

      context 'and it is defined by the last time in' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now }
        let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago }

        it { expect(demand.current_stage).to eq other_stage }
      end

      context 'and it is defined by the non existence of last time out' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }
        let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: nil }

        it { expect(demand.current_stage).to eq stage }
      end
    end

    context 'having no transitions' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customers: [customer] }

      let(:demand) { Fabricate :demand, project: project }

      it { expect(demand.current_stage).to be_nil }
    end
  end

  describe '#csv_array' do
    context 'having no stages' do
      let!(:demand) { Fabricate :demand, business_score: 10.5, effort_downstream: 0, end_date: Time.zone.today }

      it { expect(demand.csv_array).to eq [demand.id, demand.current_stage&.name, demand.project.id, demand.demand_id, demand.demand_title, demand.demand_type, demand.class_of_service, '10,5', demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.created_date&.iso8601, demand.commitment_date&.iso8601, demand.end_date&.iso8601] }
    end

    context 'having a stage and no end date' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }

      let(:project) { Fabricate :project, products: [product] }
      let!(:stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, stage_stream: :downstream, order: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }
      let!(:demand) { Fabricate :demand, project: project, business_score: 10.5, effort_downstream: 0 }

      it { expect(demand.csv_array).to eq [demand.id, demand.current_stage&.name, demand.project.id, demand.demand_id, demand.demand_title, demand.demand_type, demand.class_of_service, '10,5', demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.created_date&.iso8601, demand.commitment_date&.iso8601, nil] }
    end
  end

  describe '#leadtime_in_days' do
    context 'having leadtime' do
      let!(:demand) { Fabricate :demand }

      it { expect(demand.leadtime_in_days.to_f).to be_within(1.second).of(1) }
    end

    context 'having no leadtime' do
      let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: nil, leadtime: nil }

      it { expect(demand.leadtime_in_days.to_f).to eq 0 }
    end
  end

  describe '#partial_leadtime' do
    context 'having leadtime' do
      let!(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: 1.day.ago }

      it { expect(demand.partial_leadtime.to_f).to be_within(1.second).of(1.day) }
    end

    context 'having no leadtime' do
      let!(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: nil }

      it { expect(demand.partial_leadtime.to_f).to be_within(1.second).of(172_800.06) }
    end

    context 'having no commitment date' do
      let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: nil }

      it { expect(demand.partial_leadtime.to_f).to eq 0 }
    end
  end

  describe '#total_touch_blocked_time' do
    context 'having transitions and blocks' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let(:project) { Fabricate :project, products: [product] }

      let!(:queue_stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, queue: false, stage_stream: :downstream }
      let!(:touch_stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, queue: true, stage_stream: :downstream }

      let!(:demand) { Fabricate :demand, project: project, leadtime: 453_223 }

      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: queue_stage, last_time_in: 2.days.ago, last_time_out: 5.hours.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: touch_stage, last_time_in: 1.day.ago, last_time_out: Time.zone.now }
      let!(:discarded_demand_transition) { Fabricate :demand_transition, demand: demand, stage: touch_stage, last_time_in: 1.day.ago, last_time_out: Time.zone.now, discarded_at: Time.zone.now }

      let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_time: 40.hours.ago, unblock_time: 20.hours.ago }
      let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_time: 15.hours.ago, unblock_time: 10.hours.ago }

      let!(:discarded_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00'), discarded_at: Time.zone.now }

      it { expect(demand.total_touch_blocked_time.to_i).to eq 90_000 }
    end

    context 'having no transitions' do
      let!(:demand) { Fabricate :demand, leadtime: nil }

      it { expect(demand.total_touch_blocked_time.to_f).to eq 0 }
    end
  end

  describe '#compute_and_update_automatic_fields' do
    context 'when the end date and commitment date are not null' do
      let(:demand) { Fabricate.build :demand, commitment_date: 1.day.ago, end_date: Time.zone.now }

      before { demand.save }

      it { expect(described_class.last.leadtime.to_f).to eq((demand.end_date - demand.commitment_date)) }
    end

    context 'when the end date is null' do
      let(:demand) { Fabricate.build :demand, commitment_date: 1.day.ago, end_date: nil }

      before { demand.save }

      it { expect(described_class.last.leadtime).to be_nil }
    end

    context 'when the commitment date is null' do
      let(:demand) { Fabricate.build :demand, commitment_date: nil, end_date: Time.zone.now }

      before { demand.save }

      it { expect(described_class.last.leadtime).to be_nil }
    end
  end

  describe '#total_bloked_working_time' do
    let(:demand) { Fabricate :demand }
    let!(:demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.local(2019, 2, 25, 10, 0, 0), unblock_time: Time.zone.local(2019, 2, 25, 12, 0, 0) }
    let!(:other_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.local(2019, 2, 25, 10, 0, 0), unblock_time: Time.zone.local(2019, 2, 25, 14, 0, 0) }
    let!(:open_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.local(2019, 2, 25, 10, 0, 0), unblock_time: nil }
    let!(:removed_demand_block) { Fabricate :demand_block, demand: demand, block_time: Time.zone.local(2019, 2, 25, 10, 0, 0), unblock_time: Time.zone.local(2019, 2, 25, 14, 0, 0), discarded_at: Time.zone.today }

    it { expect(demand.total_bloked_working_time).to eq 6 }
  end

  describe '#aging_when_finished' do
    let(:demand) { Fabricate :demand, created_date: Time.zone.local(2019, 2, 8, 19, 7, 0), end_date: Time.zone.local(2019, 2, 9, 10, 7, 0) }
    let(:other_demand) { Fabricate :demand, created_date: Time.zone.local(2019, 2, 8, 19, 7, 0), end_date: nil }

    it { expect(demand.aging_when_finished).to eq 0.625 }
    it { expect(other_demand.aging_when_finished).to eq 0 }
  end

  describe '#cost_to_project' do
    context 'without effort computed' do
      let(:project) { Fabricate :project, hour_value: 100 }
      let(:demand) { Fabricate :demand, project: project, effort_downstream: 0, effort_upstream: 0 }

      it { expect(demand.cost_to_project).to eq 0 }
    end

    context 'with effort computed and project hour value' do
      let(:project) { Fabricate :project, hour_value: 100 }
      let(:demand) { Fabricate :demand, project: project, effort_downstream: 10, effort_upstream: 20 }

      it { expect(demand.cost_to_project).to eq 3000 }
    end

    context 'without project hour value' do
      let(:project) { Fabricate :project, hour_value: nil }
      let(:demand) { Fabricate :demand, project: project, effort_downstream: 10, effort_upstream: 20 }

      it { expect(demand.cost_to_project).to eq 0 }
    end
  end

  describe '#time_in_current_stage' do
    context 'without transitions' do
      let(:demand) { Fabricate :demand }

      it { expect(demand.time_in_current_stage).to eq 0 }
    end

    context 'with transitions' do
      let(:project) { Fabricate :project, hour_value: 100 }
      let(:stage) { Fabricate :stage, projects: [project] }

      let!(:demand) { Fabricate :demand, project: project }

      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago }
      let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago }

      it { expect(demand.time_in_current_stage).to be_within(0.9).of(86_400.2) }
    end
  end

  describe '#flow_percentage_concluded' do
    context 'without transitions' do
      let(:demand) { Fabricate :demand }

      it { expect(demand.flow_percentage_concluded).to eq 0 }
    end

    context 'with no downstream transitions' do
      let(:project) { Fabricate :project, hour_value: 100 }

      let!(:first_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 0 }
      let!(:second_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 1 }
      let!(:third_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 2 }
      let!(:fourth_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 3 }

      let!(:demand) { Fabricate :demand, project: project }

      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: third_stage, last_time_in: 1.day.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: second_stage, last_time_in: 2.days.ago }
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: 3.days.ago }

      it { expect(demand.flow_percentage_concluded).to eq 0 }
    end

    context 'with downstream transitions' do
      let(:project) { Fabricate :project, hour_value: 100 }

      let!(:first_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 0 }
      let!(:second_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 1 }
      let!(:third_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 2 }
      let!(:fourth_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 3 }

      let!(:demand) { Fabricate :demand, project: project }

      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: third_stage, last_time_in: 1.day.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: second_stage, last_time_in: 2.days.ago }
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: 3.days.ago }

      it { expect(demand.flow_percentage_concluded).to eq 0.6666666666666666 }
    end
  end

  describe '#beyond_limit_time?' do
    let(:company) { Fabricate :company }
    let(:stage) { Fabricate :stage, company: company }
    let(:project) { Fabricate :project, company: company }
    let!(:demand) { Fabricate :demand, project: project }

    context 'with value in stage project config' do
      let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage, project: project, max_seconds_in_stage: 24 * 60 * 60 }

      context 'with an outdated transition in the stage' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago }

        it { expect(demand.beyond_limit_time?).to be true }
      end

      context 'without an outdated transition in the stage' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.hours.ago }

        it { expect(demand.beyond_limit_time?).to be false }
      end
    end

    context 'without value in stage project config' do
      let!(:stage_project_config) { Fabricate :stage_project_config, stage: stage, project: project, max_seconds_in_stage: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.hours.ago }

      it { expect(demand.beyond_limit_time?).to be false }
    end

    context 'without stage project config' do
      it { expect(demand.beyond_limit_time?).to be false }
    end
  end

  describe '#product_tree' do
    let(:product) { Fabricate :product, name: 'Flow Climate' }

    let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Statistics' }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Lead time', parent: portfolio_unit }
    let(:grandchild_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Average', parent: child_portfolio_unit }

    let!(:demand) { Fabricate :demand, product: product, portfolio_unit: grandchild_portfolio_unit }
    let!(:product_demand) { Fabricate :demand, product: product, portfolio_unit: nil }
    let!(:no_product_demand) { Fabricate :demand, product: nil, portfolio_unit: nil }

    it { expect(demand.product_tree).to eq [product, portfolio_unit, child_portfolio_unit, grandchild_portfolio_unit, demand] }
    it { expect(product_demand.product_tree).to eq [product, product_demand] }
    it { expect(no_product_demand.product_tree).to eq [no_product_demand] }
  end

  describe '#to_hash' do
    let(:demand) { Fabricate :demand, business_score: 10.5 }

    it { expect(demand.to_hash).to eq(id: demand.id, demand_id: demand.demand_id, project_id: demand.project.id, demand_title: demand.demand_title, business_score: 10.5, effort_upstream: demand.effort_upstream, effort_downstream: demand.effort_downstream, cost_to_project: demand.cost_to_project, current_stage: demand.current_stage&.name, time_in_current_stage: demand.time_in_current_stage, partial_leadtime: demand.partial_leadtime, responsibles: demand.team_members.map { |member| { member_name: member.name, jira_account_id: member.jira_account_id } }, demand_blocks: demand.demand_blocks.map { |block| { blocker_username: block.blocker_username, block_time: block.block_time, block_reason: block.block_reason, unblock_time: block.unblock_time } }) }
  end

  describe '#assignees_count' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:first_demand) { Fabricate :demand, team: team }

    let(:first_team_member) { Fabricate :team_member, company: company }
    let(:second_team_member) { Fabricate :team_member, company: company }
    let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
    let!(:second_membership) { Fabricate :membership, team: team, team_member: second_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member, start_time: 1.day.ago, finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: second_team_member, start_time: 2.days.ago, finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }

    let(:second_demand) { Fabricate :demand, team: team }

    it { expect(first_demand.assignees_count).to eq 2 }
    it { expect(second_demand.assignees_count).to eq 0 }
  end
end
