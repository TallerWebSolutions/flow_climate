# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_type).with(feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5) }
    it { is_expected.to define_enum_for(:class_of_service).with(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to have_many(:demand_transitions).dependent(:destroy) }
    it { is_expected.to have_many(:demand_blocks).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :demand_id }
      it { is_expected.to validate_presence_of :created_date }
      it { is_expected.to validate_presence_of :demand_type }
      it { is_expected.to validate_presence_of :class_of_service }
    end

    context 'complex ones' do
      context 'demand_id uniqueness' do
        let!(:project) { Fabricate :project }
        let!(:demand) { Fabricate :demand, project: project, demand_id: 'zzz' }
        context 'same demand_id in same project' do
          let!(:other_demand) { Fabricate.build :demand, project: project, demand_id: 'zzz' }
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

    describe '.opened_in_date' do
      let!(:first_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:second_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:third_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-05 11:00') }

      it { expect(Demand.opened_in_date(Date.new(2018, 2, 3))).to match_array [first_demand, second_demand] }
    end

    describe '.opened_after_date' do
      let!(:first_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-02 11:00') }
      let!(:second_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:third_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-05 11:00') }

      it { expect(Demand.opened_after_date(Date.new(2018, 2, 3))).to match_array [second_demand, third_demand] }
    end
    describe '.finished' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: nil }

      it { expect(Demand.finished).to match_array [first_demand, second_demand] }
    end
    describe '.finished_with_leadtime' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.now, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.now, leadtime: 3 }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(Demand.finished_with_leadtime).to match_array [first_demand, second_demand] }
    end
    describe '.finished_until_date' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: 2.days.ago, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: 1.day.ago, leadtime: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(Demand.finished_until_date(1.day.ago)).to match_array [first_demand, second_demand] }
    end
    describe '.finished_until_date_with_leadtime' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: 2.days.ago, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: 1.day.ago, leadtime: 3 }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(Demand.finished_until_date_with_leadtime(1.day.ago)).to match_array [first_demand, second_demand] }
    end
    describe '.finished_after_date' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: 2.days.ago, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: 1.day.ago, leadtime: 3 }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(Demand.finished_after_date(1.day.ago)).to match_array [second_demand, third_demand] }
    end
    describe '.not_finished' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

      it { expect(Demand.not_finished).to match_array [first_demand, second_demand] }
    end
    describe '.upstream_flag' do
      let!(:first_demand) { Fabricate :demand, downstream: false }
      let!(:second_demand) { Fabricate :demand, downstream: false }
      let!(:third_demand) { Fabricate :demand, downstream: true }

      it { expect(Demand.upstream_flag).to match_array [first_demand, second_demand] }
    end
    describe '.downstream_flag' do
      let!(:first_demand) { Fabricate :demand, downstream: true }
      let!(:second_demand) { Fabricate :demand, downstream: true }
      let!(:third_demand) { Fabricate :demand, downstream: false }

      it { expect(Demand.downstream_flag).to match_array [first_demand, second_demand] }
    end
    describe '.grouped_end_date_by_month' do
      let!(:first_demand) { Fabricate :demand, downstream: true, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, downstream: true, end_date: 2.months.ago }
      let!(:third_demand) { Fabricate :demand, downstream: true, end_date: 1.month.ago }
      let!(:fourth_demand) { Fabricate :demand, downstream: false }

      it { expect(Demand.grouped_end_date_by_month[[2.months.ago.to_date.cwyear, 2.months.ago.to_date.month]]).to match_array [first_demand, second_demand] }
      it { expect(Demand.grouped_end_date_by_month[[1.month.ago.to_date.cwyear, 1.month.ago.to_date.month]]).to eq [third_demand] }
    end
    describe '.grouped_by_customer' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }

      let(:first_project) { Fabricate :project, customer: customer }
      let(:second_project) { Fabricate :project, customer: other_customer }
      let(:third_project) { Fabricate :project, customer: other_customer }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 2.months.ago }
      let!(:third_demand) { Fabricate :demand, project: second_project }
      let!(:fourth_demand) { Fabricate :demand, project: third_project }

      it { expect(Demand.grouped_by_customer[customer.name]).to match_array [first_demand, second_demand] }
      it { expect(Demand.grouped_by_customer[other_customer.name]).to match_array [third_demand, fourth_demand] }
    end

    describe '.not_discarded_until_date' do
      let!(:first_demand) { Fabricate :demand, discarded_at: 2.weeks.ago.end_of_day }
      let!(:second_demand) { Fabricate :demand, discarded_at: 1.week.ago.end_of_day }
      let!(:third_demand) { Fabricate :demand, discarded_at: 3.days.ago.end_of_day }
      let!(:fourth_demand) { Fabricate :demand, discarded_at: Time.zone.now }

      it { expect(Demand.not_discarded_until_date(1.week.ago)).to match_array [third_demand, fourth_demand] }
    end

    describe '.finished_in_month' do
      before { travel_to Date.new(2018, 10, 23) }
      after { travel_back }
      let(:first_demand) { Fabricate :demand, end_date: 2.months.ago }
      let(:second_demand) { Fabricate :demand, end_date: 1.month.ago }
      let(:third_demand) { Fabricate :demand, end_date: 1.month.ago }
      let(:fourth_demand) { Fabricate :demand, end_date: Time.zone.today }

      it { expect(Demand.finished_in_month(2.months.ago.to_date.month, 2.months.ago.to_date.year)).to eq [first_demand] }
      it { expect(Demand.finished_in_month(1.month.ago.to_date.month, 1.month.ago.to_date.year)).to match_array [second_demand, third_demand] }
      it { expect(Demand.finished_in_month(Time.zone.today.to_date.month, Time.zone.today.to_date.year)).to eq [fourth_demand] }
    end

    describe '.finished_in_week' do
      before { travel_to Date.new(2018, 10, 23) }
      after { travel_back }
      let(:first_demand) { Fabricate :demand, end_date: 2.weeks.ago }
      let(:second_demand) { Fabricate :demand, end_date: 1.week.ago }
      let(:third_demand) { Fabricate :demand, end_date: 1.week.ago }
      let(:fourth_demand) { Fabricate :demand, end_date: Time.zone.today }

      it { expect(Demand.finished_in_week(2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear)).to eq [first_demand] }
      it { expect(Demand.finished_in_week(1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [second_demand, third_demand] }
      it { expect(Demand.finished_in_week(Time.zone.today.to_date.cweek, Time.zone.today.to_date.cwyear)).to eq [fourth_demand] }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:company).to(:project) }
    it { is_expected.to delegate_method(:full_name).to(:project).with_prefix }
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
    let(:project) { Fabricate :project, customer: customer, percentage_effort_to_bugs: 20 }
    let(:upstream_effort_stage) { Fabricate :stage, stage_stream: :upstream }
    let(:downstream_effort_stage) { Fabricate :stage, stage_stream: :downstream }

    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: upstream_effort_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: project, stage: downstream_effort_stage, compute_effort: true, pairing_percentage: 20, stage_percentage: 90, management_percentage: 15 }

    context 'having only one assined' do
      context 'having no blockings' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:downstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:00'), last_time_out: Time.zone.parse('2018-03-06 15:00') }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 6.6
          expect(demand.effort_downstream.to_f).to eq 2.07
        end
      end
      context 'having blockings' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: Time.zone.parse('2018-03-06 00:00') }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00') }
        let!(:third_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 123.0, block_time: Time.zone.parse('2018-03-06 10:00') }
        let!(:out_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 5.0, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 3.6
          expect(demand.effort_downstream.to_f).to eq 0.0
        end
      end

      context 'having no transition in the effort stage' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1, effort_upstream: 0, effort_downstream: 0 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        it 'does not change the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 0.0
          expect(demand.effort_downstream.to_f).to eq 0.0
        end
      end
    end

    context 'having a pair assigned' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 2, effort_upstream: 0, effort_downstream: 0 }
      context 'having no blockings' do
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:downstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:00'), last_time_out: Time.zone.parse('2018-03-06 15:00') }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 10.56
          expect(demand.effort_downstream.to_f).to eq 2.484
        end
      end
      context 'having blockings' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
        let!(:out_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }

        it 'changes the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 7.56
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
        let(:demand) { Fabricate :demand, project: project, assignees_count: 2, effort_upstream: 30, effort_downstream: 23, manual_effort: true }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        it 'does not change the effort informations' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 30.0
          expect(demand.effort_downstream.to_f).to eq 23.0
        end
      end

      context 'when the demand is a bug' do
        let(:demand) { Fabricate :demand, project: project, demand_type: :bug, assignees_count: 2, effort_upstream: 30, effort_downstream: 23, manual_effort: false }
        let!(:upstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-20 13:00') }
        let!(:downstream_demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_effort_stage, last_time_in: Time.zone.parse('2018-03-06 13:00'), last_time_out: Time.zone.parse('2018-03-14 15:00') }

        it 'changes the effort based on the bug configuration' do
          demand.update_effort!
          expect(demand.effort_upstream.to_f).to eq 23.232
          expect(demand.effort_downstream.to_f).to eq 9.4392
        end
      end
    end
  end

  context 'computed fields' do
    context 'leadtime' do
      context 'having commitment and end dates' do
        let!(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: 1.hour.ago }
        it { expect(demand.leadtime).to be_within(0.001).of(169_200.001) }
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

  describe '#result_date' do
    context 'having end_date' do
      let!(:demand) { Fabricate :demand, end_date: Time.zone.parse('2018-03-15 16:24:41 -3') }
      it { expect(demand.result_date).to eq Date.new(2018, 3, 15) }
    end
    context 'having no end_date' do
      let!(:demand) { Fabricate :demand, end_date: nil }
      it { expect(demand.result_date).to eq demand.created_date.to_date }
    end

    context 'having the end_date in the edge of timezone' do
      let!(:demand) { Fabricate :demand, end_date: Time.zone.parse('2018-03-15 23:24:41 -3') }
      it { expect(demand.result_date).to eq Date.new(2018, 3, 16) }
    end
  end

  describe '#working_time_upstream' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:other_project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, stage_stream: :upstream }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: effort_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 90, management_percentage: 20 }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: other_project, stage: effort_stage, compute_effort: true, pairing_percentage: 40, stage_percentage: 100, management_percentage: 10 }

    context 'having only one assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      let(:other_demand) { Fabricate :demand, project: other_project, assignees_count: 1 }
      let!(:other_demand_transition) { Fabricate :demand_transition, demand: other_demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-08 22:00'), last_time_out: Time.zone.parse('2018-03-20 20:00') }

      it { expect(demand.working_time_upstream.to_f).to eq 6.48 }
    end

    context 'having a pair assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 2, effort_upstream: 0, effort_downstream: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.working_time_upstream.to_f).to eq 10.368 }
    end
  end

  describe '#working_time_downstream' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:other_project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, stage_stream: :downstream }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: effort_stage, compute_effort: true, pairing_percentage: 80, stage_percentage: 100, management_percentage: 10 }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: other_project, stage: effort_stage, compute_effort: true, pairing_percentage: 30, stage_percentage: 90, management_percentage: 10 }

    context 'having only one assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      let(:other_demand) { Fabricate :demand, project: other_project, assignees_count: 1 }
      let!(:other_demand_transition) { Fabricate :demand_transition, demand: other_demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-08 22:00'), last_time_out: Time.zone.parse('2018-03-20 20:00') }

      it { expect(demand.working_time_downstream.to_f).to eq 6.6000000000000005 }
    end

    context 'having a pair assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 2, effort_upstream: 0, effort_downstream: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.working_time_downstream.to_f).to eq 11.880000000000003 }
    end
  end

  describe '#blocked_working_time_upstream' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, stage_stream: :upstream }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: effort_stage, compute_effort: true }
    let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }

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

      it { expect(demand.blocked_working_time_upstream.to_f).to eq 3.0 }
    end
  end

  describe '#blocked_working_time_downstream' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, stage_stream: :downstream }
    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: effort_stage, compute_effort: true }
    let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }

    context 'having no blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.blocked_working_time_downstream.to_f).to eq 0.0 }
    end
    context 'having blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
      let!(:first_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:second_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:third_demand_block) { Fabricate :demand_block, demand: demand, active: false, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:out_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }

      it { expect(demand.blocked_working_time_downstream.to_f).to eq 3.0 }
    end
  end

  describe '#downstream_demand?' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:downstream_stage) { Fabricate :stage, stage_stream: :downstream }
    let(:upstream_stage) { Fabricate :stage, stage_stream: :upstream }

    let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: upstream_stage }
    let!(:other_stage_project_config) { Fabricate :stage_project_config, project: project, stage: downstream_stage }

    let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }

    context 'having transition in the downstream' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: downstream_stage }
      it { expect(demand.downstream_demand?).to be true }
    end

    context 'having no transitions in the downstream' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: upstream_stage }
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
      let(:project) { Fabricate :project, customer: customer }
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
      let(:project) { Fabricate :project, customer: customer }

      let(:demand) { Fabricate :demand, project: project }
      it { expect(demand.current_stage).to be_nil }
    end
  end

  describe '#flowing?' do
    context 'having transitions' do
      context 'and it started to flow and returned to backlog' do
        let(:company) { Fabricate :company }
        let(:customer) { Fabricate :customer, company: company }
        let(:project) { Fabricate :project, customer: customer }
        let(:stage) { Fabricate :stage, company: company, projects: [project], order: 0 }
        let(:other_stage) { Fabricate :stage, company: company, projects: [project], order: 1 }

        let(:demand) { Fabricate :demand, project: project }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now }
        let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago }

        it { expect(demand.flowing?).to be false }
      end
      context 'and it started to flow' do
        let(:company) { Fabricate :company }
        let(:customer) { Fabricate :customer, company: company }
        let(:project) { Fabricate :project, customer: customer }
        let(:stage) { Fabricate :stage, company: company, projects: [project], order: 0 }
        let(:other_stage) { Fabricate :stage, company: company, projects: [project], order: 1 }

        let(:demand) { Fabricate :demand, project: project }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago }
        let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now }

        it { expect(demand.flowing?).to be true }
      end

      context 'and it has ended' do
        let(:company) { Fabricate :company }
        let(:customer) { Fabricate :customer, company: company }
        let(:project) { Fabricate :project, customer: customer }
        let(:stage) { Fabricate :stage, company: company, projects: [project], order: 0 }
        let(:other_stage) { Fabricate :stage, company: company, projects: [project], order: 1 }

        let(:demand) { Fabricate :demand, project: project, end_date: Time.zone.now }

        it { expect(demand.flowing?).to be false }
      end
    end

    context 'having no transitions' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }

      context 'and the demand has no commitment date' do
        let(:demand) { Fabricate :demand, project: project }
        it { expect(demand.flowing?).to be false }
      end

      context 'and the demand has commitment date' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }
        it { expect(demand.flowing?).to be true }
      end
    end
  end

  describe '#committed?' do
    context 'having transitions' do
      context 'and it went to the commitment area and returned' do
        let(:company) { Fabricate :company }
        let(:customer) { Fabricate :customer, company: company }
        let(:project) { Fabricate :project, customer: customer }
        let(:stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, order: 0 }
        let(:commitment_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, order: 1, commitment_point: true }
        let(:end_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, order: 2, end_point: true }

        let(:demand) { Fabricate :demand, project: project }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now }
        let!(:commitment_demand_transition) { Fabricate :demand_transition, demand: demand, stage: commitment_stage, last_time_in: 1.day.ago }
        let!(:end_demand_transition) { Fabricate :demand_transition, demand: demand, stage: end_stage, last_time_in: Time.zone.tomorrow }

        it { expect(demand.committed?).to be false }
      end
      context 'and it was committed' do
        let(:company) { Fabricate :company }
        let(:customer) { Fabricate :customer, company: company }
        let(:project) { Fabricate :project, customer: customer }
        let(:stage) { Fabricate :stage, company: company, projects: [project], order: 0 }
        let(:other_stage) { Fabricate :stage, company: company, projects: [project], order: 1, commitment_point: true }

        let(:demand) { Fabricate :demand, project: project }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago }
        let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now }

        it { expect(demand.committed?).to be true }
      end
      context 'and it was committed and finished' do
        let(:company) { Fabricate :company }
        let(:customer) { Fabricate :customer, company: company }
        let(:project) { Fabricate :project, customer: customer }
        let(:stage) { Fabricate :stage, company: company, projects: [project], order: 0 }
        let(:other_stage) { Fabricate :stage, company: company, projects: [project], order: 1, commitment_point: true }
        let(:end_stage) { Fabricate :stage, company: company, projects: [project], order: 1, end_point: true }

        let(:demand) { Fabricate :demand, project: project }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago }
        let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 4.hours.ago }
        let!(:fourth_demand_transition) { Fabricate :demand_transition, demand: demand, stage: end_stage, last_time_in: Time.zone.now }

        it { expect(demand.committed?).to be false }
      end
    end

    context 'having no transitions' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }

      context 'and the demand has no commitment date' do
        let(:demand) { Fabricate :demand, project: project }
        it { expect(demand.committed?).to be false }
      end

      context 'and the demand has commitment date' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }
        it { expect(demand.committed?).to be true }
      end

      context 'and the demand has commitment date and end_date' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: 1.hour.from_now }
        it { expect(demand.committed?).to be false }
      end
    end
  end

  describe '#update_commitment_date!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:stage) { Fabricate :stage, company: company, projects: [project], order: 0 }
    let(:other_stage) { Fabricate :stage, company: company, projects: [project], order: 1, commitment_point: true }

    context 'having stages' do
      context 'and the demand is inside commitment area' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago, last_time_out: Time.zone.now }

        before { demand.update_commitment_date! }

        it { expect(demand.commitment_date).not_to be_nil }
      end

      context 'and the demand went to outside commitment area' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago, last_time_out: Time.zone.now }
        let!(:third_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

        before { demand.update_commitment_date! }

        it { expect(demand.commitment_date).to be_nil }
      end

      context 'and the demand went to outside commitment area via last time out nil' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }
        let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: nil }
        let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: 1.day.ago, last_time_out: Time.zone.now }

        before { demand.update_commitment_date! }

        it { expect(demand.commitment_date).to be_nil }
      end
    end

    context 'having no stages' do
      context 'and the demand is inside commitment area' do
        let(:demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now }
        it { expect { demand.update_commitment_date! }.not_to raise_error Exception }
      end
    end
  end

  describe '#archived?' do
    let(:project) { Fabricate :project }

    let!(:not_archived) { Fabricate :stage, stage_type: :development, projects: [project] }
    let(:demand) { Fabricate :demand, project: project }
    let!(:demand_transition) { Fabricate :demand_transition, stage: not_archived, demand: demand }

    context 'having transition in an archived stage' do
      let!(:archived_stage) { Fabricate :stage, stage_type: :archived, projects: [project] }
      let!(:archived_demand_transition) { Fabricate :demand_transition, stage: archived_stage, demand: demand }
      it { expect(demand.reload).to be_archived }
    end

    context 'having no transition in an archived stage' do
      it { expect(demand.reload).not_to be_archived }
    end
  end

  describe '#csv_array' do
    context 'having no stages' do
      let!(:demand) { Fabricate :demand, effort_downstream: nil, end_date: Time.zone.today }
      it { expect(demand.csv_array).to eq [demand.id, demand.demand_id, demand.demand_title, nil, demand.demand_id, demand.demand_type, demand.class_of_service, demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.created_date&.iso8601, demand.commitment_date&.iso8601, demand.end_date&.iso8601] }
    end

    context 'having a stage and no end date' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let(:project) { Fabricate :project, product: product }
      let!(:stage) { Fabricate :stage, company: company, projects: [project], end_point: false, commitment_point: false, stage_stream: :downstream, order: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }
      let!(:demand) { Fabricate :demand, project: project, effort_downstream: nil }

      it { expect(demand.csv_array).to eq [demand.id, demand.demand_id, demand.demand_title, stage.name, demand.demand_id, demand.demand_type, demand.class_of_service, demand.effort_downstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.effort_upstream.to_f.to_s.gsub('.', I18n.t('number.format.separator')), demand.created_date&.iso8601, demand.commitment_date&.iso8601, nil] }
    end
  end

  describe '#leadtime_in_days' do
    context 'having leadtime' do
      let!(:demand) { Fabricate :demand, leadtime: 453_223 }
      it { expect(demand.leadtime_in_days.to_f).to eq 5.245636574074074 }
    end
    context 'having no leadtime' do
      let!(:demand) { Fabricate :demand, leadtime: nil }
      it { expect(demand.leadtime_in_days.to_f).to eq 0 }
    end
  end
end
