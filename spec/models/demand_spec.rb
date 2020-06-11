# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_type).with_values(feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5) }
    it { is_expected.to define_enum_for(:class_of_service).with_values(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :portfolio_unit }
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :risk_review }
    it { is_expected.to belong_to :service_delivery_review }
    it { is_expected.to belong_to(:current_stage).class_name('Stage').inverse_of(:current_demands) }

    it { is_expected.to have_many(:demand_transitions).dependent(:destroy) }
    it { is_expected.to have_many(:demand_blocks).dependent(:destroy) }
    it { is_expected.to have_many(:demand_comments).dependent(:destroy) }
    it { is_expected.to have_many(:flow_impacts).dependent(:destroy) }
    it { is_expected.to have_many(:stages).through(:demand_transitions) }

    it { is_expected.to have_many(:item_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:team_members).through(:item_assignments) }
    it { is_expected.to have_many(:demand_score_matrices).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :team }
      it { is_expected.to validate_presence_of :external_id }
      it { is_expected.to validate_presence_of :created_date }
      it { is_expected.to validate_presence_of :demand_type }
      it { is_expected.to validate_presence_of :class_of_service }
    end

    context 'complex ones' do
      context 'external_id uniqueness' do
        let!(:project) { Fabricate :project }
        let!(:demand) { Fabricate :demand, project: project, company: project.company, external_id: 'zzz' }

        context 'same external_id in same project' do
          let!(:other_demand) { Fabricate.build :demand, project: project, company: project.company, external_id: 'zzz' }

          it 'does not accept the model' do
            expect(other_demand.valid?).to be false
            expect(other_demand.errors[:external_id]).to eq [I18n.t('demand.validations.external_id_unique.message')]
          end
        end

        context 'different external_id in same customer' do
          let!(:other_demand) { Fabricate.build :demand, project: project, external_id: 'aaa' }

          it { expect(other_demand.valid?).to be true }
        end

        context 'same external_id in different project' do
          let!(:other_demand) { Fabricate.build :demand, external_id: 'zzz' }

          it { expect(other_demand.valid?).to be true }
        end
      end
    end
  end

  context 'scopes' do
    let(:project) { Fabricate :project }

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
      let!(:one_day_ago) { 1.day.ago }
      let!(:two_days_ago) { 2.days.ago }

      let!(:first_demand) { Fabricate :demand, project: project, end_date: two_days_ago, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: one_day_ago, leadtime: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(described_class.finished_after_date(one_day_ago)).to match_array [second_demand, third_demand] }
    end

    describe '.not_finished' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(described_class.not_finished).to match_array [first_demand, second_demand] }
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

      it { expect(described_class.to_dates(1.month.ago, Time.zone.now).map(&:id)).to match_array [second_demand.id, third_demand.id] }
    end

    describe '.to_end_dates' do
      let!(:first_demand) { Fabricate :demand, created_date: 3.months.ago, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, created_date: 1.month.ago, end_date: 15.days.ago }
      let!(:third_demand) { Fabricate :demand, created_date: 2.months.ago, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, created_date: 4.months.ago, end_date: 1.day.from_now }

      let!(:fifth_demand) { Fabricate :demand, created_date: 1.month.ago, end_date: nil }

      it { expect(described_class.to_end_dates(1.month.ago, Time.zone.now).map(&:id)).to match_array [second_demand.id, third_demand.id] }
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

    describe '.with_effort' do
      it 'returns only the demands with effort' do
        first_demand = Fabricate :demand, project: project, effort_downstream: 10, effort_upstream: 0
        second_demand = Fabricate :demand, project: project, effort_downstream: 0, effort_upstream: 10
        Fabricate :demand, project: project, effort_downstream: 0, effort_upstream: 0

        expect(described_class.with_effort.map(&:id)).to match_array [first_demand.id, second_demand.id]
      end
    end

    describe '.grouped_end_date_by_month' do
      let!(:first_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: 2.months.ago }
      let!(:third_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: 1.month.ago }
      let!(:fourth_demand) { Fabricate :demand, commitment_date: nil }

      it { expect(described_class.grouped_end_date_by_month[[2.months.ago.to_date.cwyear, 2.months.ago.to_date.month]].map(&:id)).to match_array [first_demand.id, second_demand.id] }
      it { expect(described_class.grouped_end_date_by_month[[1.month.ago.to_date.cwyear, 1.month.ago.to_date.month]].map(&:id)).to eq [third_demand.id] }
    end

    describe '.not_started' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: nil }

      it { expect(described_class.not_started.map(&:id)).to match_array [third_demand.id] }
    end

    describe '.opened_before_date' do
      let!(:first_demand) { Fabricate :demand, external_id: 'first_demand', created_date: 4.days.ago, end_date: 3.days.ago, discarded_at: nil }
      let!(:second_demand) { Fabricate :demand, external_id: 'second_demand', created_date: 3.days.ago, end_date: 2.days.ago, discarded_at: nil }
      let!(:third_demand) { Fabricate :demand, external_id: 'third_demand', created_date: 2.days.ago, end_date: nil, discarded_at: nil }
      let!(:fourth_demand) { Fabricate :demand, external_id: 'fourth_demand', created_date: 1.day.ago, end_date: 1.day.ago, discarded_at: nil }
      let!(:fifth_demand) { Fabricate :demand, external_id: 'fifth_demand', created_date: 2.days.ago, end_date: 2.days.ago, discarded_at: nil }

      let!(:sixth_demand) { Fabricate :demand, external_id: 'sixth_demand', discarded_at: Time.zone.today }

      it { expect(described_class.opened_before_date(Time.zone.now).map(&:external_id)).to match_array [first_demand.external_id, second_demand.external_id, third_demand.external_id, fifth_demand.external_id, fourth_demand.external_id] }
    end

    pending '.unscored_demands'
    pending '.with_valid_leadtime'
    pending '.dates_inconsistent_to_project'
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:project).with_prefix }
    it { is_expected.to delegate_method(:name).to(:customer).with_prefix }
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
    it { is_expected.to delegate_method(:name).to(:portfolio_unit).with_prefix }
    it { is_expected.to delegate_method(:name).to(:team).with_prefix }
    it { is_expected.to delegate_method(:count).to(:demand_blocks).with_prefix }
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
        let!(:discarded_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:10'), last_time_out: Time.zone.parse('2018-03-06 15:00'), discarded_at: Time.zone.now }

        let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: Time.zone.parse('2018-03-05 22:00'), finish_time: nil }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 6.6
          expect(demand.effort_downstream.to_f).to eq 4.14
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
          expect(demand.effort_upstream.to_f).to eq 6.6
          expect(demand.effort_downstream.to_f).to eq 2.3
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
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    after { travel_back }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let(:first_project) { Fabricate :project, customers: [customer], products: [product], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10, value: 1000, hour_value: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true, commitment_point: true, end_point: false }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, commitment_point: false, end_point: false }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true, commitment_point: false, end_point: true }

    let!(:queue_ongoing_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:touch_ongoing_second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: first_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: second_stage, compute_effort: true, pairing_percentage: 20, stage_percentage: 30, management_percentage: 20 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: third_stage, compute_effort: true, pairing_percentage: 40, stage_percentage: 10, management_percentage: 15 }

    let!(:first_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), end_date: nil, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, end_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5 }
    let!(:third_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'third_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 10, 23, 1, 46), end_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5 }

    let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.local(2018, 2, 27, 17, 30, 58), unblock_time: Time.zone.local(2018, 3, 1, 17, 9, 58), active: true }
    let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.local(2018, 3, 2, 17, 9, 58), unblock_time: Time.zone.local(2018, 3, 3, 11, 9, 58), active: true }
    let!(:third_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.local(2018, 3, 3, 11, 9, 58), unblock_time: Time.zone.local(2018, 3, 4, 9, 9, 58), active: true }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }

    let!(:queue_ongoing_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 14, 17, 9, 58) }
    let!(:touch_ongoing_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 19, 17, 9, 58) }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58) }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 5, 17, 9, 58) }
    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 5, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 6, 14, 9, 58) }

    it 'computes the correct values' do
      expect(first_demand.leadtime.to_f).to eq 518_400.0
      expect(first_demand.total_queue_time.to_f).to eq 748_800.0
      expect(first_demand.total_touch_time.to_f).to eq 892_800.0
      expect(first_demand.blocked_working_time_downstream.to_f).to eq 24.0
      expect(first_demand.blocked_working_time_upstream.to_f).to eq 0.0
      expect(first_demand.total_bloked_working_time.to_f).to eq 18.0
      expect(first_demand.total_touch_blocked_time.to_f).to eq 144_000.0
      expect(first_demand.cost_to_project.to_f).to eq 609.1200000000001

      expect(second_demand.leadtime.to_f).to eq 0
      expect(second_demand.total_queue_time.to_f).to eq 0
      expect(second_demand.total_touch_time.to_f).to eq 0
      expect(second_demand.blocked_working_time_downstream.to_f).to eq 0
      expect(second_demand.blocked_working_time_upstream.to_f).to eq 0
      expect(second_demand.total_bloked_working_time.to_f).to eq 0
      expect(second_demand.total_touch_blocked_time.to_f).to eq 0
      expect(second_demand.cost_to_project.to_f).to eq 150

      expect(third_demand.leadtime.to_f).to eq 781_200.0
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
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: nil }
        let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: Time.zone.tomorrow }

        it { expect(demand.current_stage).to eq other_stage }
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
      let(:product) { Fabricate :product, name: 'Flow Climate' }

      let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Statistics' }
      let(:child_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Lead time', parent: portfolio_unit }

      let!(:demand_with_portfolio_unit) { Fabricate :demand, product: product, portfolio_unit: child_portfolio_unit }
      let!(:demand) { Fabricate :demand, product: product, demand_score: 10.5, effort_downstream: 0, end_date: Time.zone.today }

      it { expect(demand.csv_array).to eq [demand.id, demand.portfolio_unit_name, demand.current_stage&.name, demand.project.id, demand.external_id, demand.demand_title, demand.demand_type, demand.class_of_service, '10,5', demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.created_date&.iso8601, demand.commitment_date&.iso8601, demand.end_date&.iso8601] }
      it { expect(demand_with_portfolio_unit.csv_array).to eq [demand_with_portfolio_unit.id, demand_with_portfolio_unit.portfolio_unit_name, demand_with_portfolio_unit.current_stage&.name, demand_with_portfolio_unit.project.id, demand_with_portfolio_unit.external_id, demand_with_portfolio_unit.demand_title, demand_with_portfolio_unit.demand_type, demand_with_portfolio_unit.class_of_service, '0,0', demand_with_portfolio_unit.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand_with_portfolio_unit.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand_with_portfolio_unit.created_date&.iso8601, demand_with_portfolio_unit.commitment_date&.iso8601, demand_with_portfolio_unit.end_date&.iso8601] }
    end

    context 'having a stage and no end date' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }

      let(:project) { Fabricate :project, products: [product] }
      let!(:stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, stage_stream: :downstream, order: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }
      let!(:demand) { Fabricate :demand, product: product, project: project, demand_score: 10.5, effort_downstream: 0 }

      it { expect(demand.csv_array).to eq [demand.id, demand.portfolio_unit_name, demand.current_stage&.name, demand.project.id, demand.external_id, demand.demand_title, demand.demand_type, demand.class_of_service, '10,5', demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.created_date&.iso8601, demand.commitment_date&.iso8601, nil] }
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
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    after { travel_back }

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
    context 'with transitions and blocks' do
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

    context 'with no transitions' do
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
    let(:project) { Fabricate :project, hour_value: 100 }

    let!(:first_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 0 }
    let!(:second_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 1 }
    let!(:third_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 2 }

    let!(:fourth_stage) { Fabricate :stage, projects: [project], commitment_point: true, stage_stream: :downstream, order: 3 }
    let!(:fifth_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 4 }
    let!(:sixth_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 5 }

    let!(:demand) { Fabricate :demand, project: project }

    context 'without transitions' do
      it { expect(demand.flow_percentage_concluded).to eq 0 }
    end

    context 'with no downstream transitions' do
      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: third_stage, last_time_in: 1.day.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: second_stage, last_time_in: 2.days.ago }
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: 3.days.ago }

      it { expect(demand.flow_percentage_concluded).to eq 0 }
    end

    context 'with downstream transitions' do
      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: fifth_stage, last_time_in: 2.days.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: fourth_stage, last_time_in: 3.days.ago }

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
    let(:product) { Fabricate :product, name: 'Flow Climate' }

    let(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Statistics' }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'Lead time', parent: portfolio_unit }

    let!(:demand_with_portfolio_unit) { Fabricate :demand, product: product, portfolio_unit: child_portfolio_unit }
    let(:demand) { Fabricate :demand, demand_score: 10.5 }

    it { expect(demand.to_hash).to eq(id: demand.id, portfolio_unit: demand.portfolio_unit_name, external_id: demand.external_id, project_id: demand.project.id, demand_title: demand.demand_title, demand_score: 10.5, effort_upstream: demand.effort_upstream, effort_downstream: demand.effort_downstream, cost_to_project: demand.cost_to_project, current_stage: demand.current_stage&.name, time_in_current_stage: demand.time_in_current_stage, partial_leadtime: demand.partial_leadtime, responsibles: demand.team_members.map { |member| { member_name: member.name, jira_account_id: member.jira_account_id } }, demand_blocks: demand.demand_blocks.map { |block| { blocker_username: block.blocker_username, block_time: block.block_time, block_reason: block.block_reason, unblock_time: block.unblock_time } }) }
    it { expect(demand_with_portfolio_unit.to_hash).to eq(id: demand_with_portfolio_unit.id, portfolio_unit: demand_with_portfolio_unit.portfolio_unit_name, external_id: demand_with_portfolio_unit.external_id, project_id: demand_with_portfolio_unit.project.id, demand_title: demand_with_portfolio_unit.demand_title, demand_score: 0, effort_upstream: demand_with_portfolio_unit.effort_upstream, effort_downstream: demand_with_portfolio_unit.effort_downstream, cost_to_project: demand_with_portfolio_unit.cost_to_project, current_stage: demand_with_portfolio_unit.current_stage&.name, time_in_current_stage: demand_with_portfolio_unit.time_in_current_stage, partial_leadtime: demand_with_portfolio_unit.partial_leadtime, responsibles: demand_with_portfolio_unit.team_members.map { |member| { member_name: member.name, jira_account_id: member.jira_account_id } }, demand_blocks: demand_with_portfolio_unit.demand_blocks.map { |block| { blocker_username: block.blocker_username, block_time: block.block_time, block_reason: block.block_reason, unblock_time: block.unblock_time } }) }
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

  describe '#time_between_commitment_and_pull' do
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    after { travel_back }

    let(:project) { Fabricate :project, hour_value: 100 }

    let!(:first_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 0 }
    let!(:second_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 1 }
    let!(:third_stage) { Fabricate :stage, projects: [project], stage_stream: :upstream, order: 2 }

    let!(:fourth_stage) { Fabricate :stage, projects: [project], commitment_point: true, stage_stream: :downstream, order: 3 }
    let!(:fifth_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 4 }
    let!(:sixth_stage) { Fabricate :stage, projects: [project], stage_stream: :downstream, order: 5 }

    let!(:demand) { Fabricate :demand, project: project }

    context 'without transitions' do
      it { expect(demand.time_between_commitment_and_pull).to eq 0 }
    end

    context 'with only upstream transitions' do
      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: third_stage, last_time_in: 1.day.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: second_stage, last_time_in: 2.days.ago }
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: 3.days.ago }

      it { expect(demand.time_between_commitment_and_pull).to eq 0 }
    end

    context 'with downstream transitions' do
      let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: sixth_stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: fifth_stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: fourth_stage, last_time_in: 3.days.ago, last_time_out: 2.days.ago }

      it { expect(demand.time_between_commitment_and_pull).to be_within(0.001).of(86_400.000) }
    end

    context 'with only ongoing downstream transitions' do
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: fourth_stage, last_time_in: 3.days.ago, last_time_out: nil }

      it { expect(demand.time_between_commitment_and_pull).to eq 0 }
    end
  end

  describe '#first_stage_in_the_flow' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let!(:first_stage) { Fabricate :stage, teams: [team], stage_stream: :upstream, order: 0 }
    let!(:second_stage) { Fabricate :stage, teams: [team], stage_stream: :upstream, order: 1 }
    let!(:third_stage) { Fabricate :stage, teams: [team], stage_stream: :upstream, order: -1 }

    context 'with stages' do
      let!(:demand) { Fabricate :demand, team: team }
      let!(:other_demand) { Fabricate :demand }

      it { expect(demand.first_stage_in_the_flow).to eq first_stage }
      it { expect(other_demand.first_stage_in_the_flow).to be_nil }
    end

    context 'with no stages' do
      let!(:project) { Fabricate :project, team: team, stages: [first_stage, second_stage, third_stage] }
      let!(:demand) { Fabricate :demand, team: team, project: project }
      let!(:other_demand) { Fabricate :demand }

      it { expect(demand.first_stage_in_the_flow).to eq first_stage }
      it { expect(other_demand.first_stage_in_the_flow).to be_nil }
    end
  end

  describe '#not_started?' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let!(:first_demand) { Fabricate :demand, team: team, commitment_date: nil, end_date: nil }
    let!(:second_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: nil }
    let!(:third_demand) { Fabricate :demand, commitment_date: nil, end_date: Time.zone.now }

    it { expect(first_demand.not_started?).to be true }
    it { expect(second_demand.not_started?).to be false }
    it { expect(third_demand.not_started?).to be false }
  end

  describe '#memberships_for_assignment' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let(:team_member) { Fabricate :team_member, company: company }
    let(:other_team_member) { Fabricate :team_member, company: company }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, end_date: nil }
    let!(:other_membership) { Fabricate :membership, team: team, team_member: team_member, start_date: 2.months.ago, end_date: 1.month.ago }

    let!(:demand) { Fabricate :demand, team: team }
    let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member }
    let!(:other_item_assignment) { Fabricate :item_assignment, demand: demand, team_member: other_team_member }

    it { expect(demand.memberships_for_assignment(item_assignment)).to match_array [membership, other_membership] }
    it { expect(demand.memberships_for_assignment(other_item_assignment)).to eq [] }
  end

  describe '#stages_at' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let!(:project) { Fabricate :project, company: company }

    let(:first_stage) { Fabricate :stage, company: company, teams: [team], projects: [project], name: 'first_stage' }
    let(:second_stage) { Fabricate :stage, company: company, teams: [team], projects: [project], name: 'second_stage' }
    let(:third_stage) { Fabricate :stage, company: company, teams: [team], projects: [project], name: 'third_stage' }
    let(:fourth_stage) { Fabricate :stage, company: company, teams: [team], projects: [project], name: 'fourth_stage' }

    let!(:demand) { Fabricate :demand, team: team, project: project, company: company }
    let!(:first_demand_transtion) { Fabricate :demand_transition, demand: demand,  stage: first_stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
    let!(:second_demand_transtion) { Fabricate :demand_transition, demand: demand, stage: second_stage, last_time_in: 3.days.ago, last_time_out: 2.days.ago }
    let!(:third_demand_transtion) { Fabricate :demand_transition, demand: demand, stage: third_stage, last_time_in: 5.days.ago, last_time_out: 4.days.ago }
    let!(:fourth_demand_transtion) { Fabricate :demand_transition, demand: demand, stage: fourth_stage, last_time_in: 3.days.ago, last_time_out: nil }

    it { expect(demand.stages_at(27.hours.ago, 26.hours.ago)).to eq [first_stage, fourth_stage] }
    it { expect(demand.stages_at(50.hours.ago, 1.hour.ago)).to eq [first_stage, second_stage, fourth_stage] }
    it { expect(demand.stages_at(100.hours.ago, 1.hour.ago)).to eq [first_stage, second_stage, third_stage, fourth_stage] }
    it { expect(demand.stages_at(100.hours.ago, 97.hours.ago)).to eq [third_stage] }
    it { expect(demand.stages_at(80.hours.ago, nil)).to eq [first_stage, second_stage, fourth_stage] }
    it { expect(demand.stages_at(1.hour.ago, 1.minute.ago)).to eq [fourth_stage] }
    it { expect(demand.stages_at(7.weeks.ago, 5.weeks.ago)).to eq [] }
  end
end
