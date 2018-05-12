# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_type).with(feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4) }
    it { is_expected.to define_enum_for(:class_of_service).with(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :project_result }
    it { is_expected.to have_many(:demand_transitions).dependent(:destroy) }
    it { is_expected.to have_many(:demand_blocks).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :demand_id }
    it { is_expected.to validate_presence_of :created_date }
    it { is_expected.to validate_presence_of :demand_type }
    it { is_expected.to validate_presence_of :class_of_service }
  end

  context 'scopes' do
    let(:project) { Fabricate :project }

    describe '.opened_in_date' do
      let!(:first_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:second_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:third_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-05 11:00') }

      it { expect(Demand.opened_in_date(Date.new(2018, 2, 3))).to match_array [first_demand, second_demand] }
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
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:company).to(:project) }
    it { is_expected.to delegate_method(:full_name).to(:project).with_prefix }
  end

  describe '.to_csv' do
    let!(:demand) { Fabricate :demand }
    let!(:other_demand) { Fabricate :demand }

    it 'builds the CSV structure' do
      generated_csv = CSV.generate do |csv|
        csv << Demand.column_names
        Demand.all.find_each do |demand|
          csv << demand.attributes.values_at(*Demand.column_names)
        end
      end
      expect(Demand.to_csv).to eq generated_csv
    end
  end

  describe '#update_effort!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
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

    context 'having a pair assined' do
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
end
