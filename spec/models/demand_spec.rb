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
    describe '.opened_in_date' do
      let!(:first_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:second_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-03 11:00') }
      let!(:third_demand) { Fabricate :demand, created_date: Time.zone.parse('2018-02-05 11:00') }

      it { expect(Demand.opened_in_date(Date.new(2018, 2, 3))).to match_array [first_demand, second_demand] }
    end

    describe '.finished' do
      let!(:first_demand) { Fabricate :demand }
      let!(:second_demand) { Fabricate :demand }
      let!(:third_demand) { Fabricate :demand }

      let(:not_end_stage) { Fabricate :stage, commitment_point: false, end_point: false }
      let(:end_stage) { Fabricate :stage, commitment_point: false, end_point: true }

      let!(:first_demand_transition) { Fabricate :demand_transition, demand: first_demand, stage: end_stage }
      let!(:second_demand_transition) { Fabricate :demand_transition, demand: second_demand, stage: end_stage }
      let!(:third_demand_transition) { Fabricate :demand_transition, demand: third_demand, stage: not_end_stage }

      it { expect(Demand.finished).to match_array [first_demand, second_demand] }
    end

    pending '.demands_with_integration'
  end

  describe '#update_effort!' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, projects: [project], compute_effort: true }

    context 'having only one assined' do
      context 'having no blockings' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 6.0 }
      end
      context 'having blockings' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: Time.zone.parse('2018-03-06 00:00') }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 12:00') }
        let!(:third_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 123.0, block_time: Time.zone.parse('2018-03-06 10:00') }
        let!(:out_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 5.0, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 3.0 }
      end

      context 'having no transition in the effort stage' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1, effort: 0 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 0.0 }
      end
    end

    context 'having a pair assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 2, effort: 0 }
      context 'having no blockings' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 9.0 }
      end
      context 'having blockings' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
        let!(:out_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 6.0 }
      end

      context 'having no transition in the effort stage' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 0.0 }
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

  describe '#leadtime' do
    context 'having commitment and end dates' do
      let(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: 1.hour.ago }
      it { expect(demand.leadtime).to be_within(0.001).of(169_200.001) }
    end
    context 'having no commitment date but having end date' do
      let(:demand) { Fabricate :demand, commitment_date: nil, end_date: 1.hour.ago }
      it { expect(demand.leadtime).to eq 0 }
    end
    context 'having commitment date but no end date' do
      let(:demand) { Fabricate :demand, commitment_date: 2.days.ago, end_date: nil }
      it { expect(demand.leadtime).to eq 0 }
    end
  end

  describe '#total_working_time' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, projects: [project], compute_effort: true }

    context 'having only one assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.total_working_time.to_f).to eq 6.0 }
    end

    context 'having a pair assined' do
      let(:demand) { Fabricate :demand, project: project, assignees_count: 2, effort: 0 }
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.total_working_time.to_f).to eq 9.0 }
    end
  end

  describe '#blocked_working_time' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }
    let(:effort_stage) { Fabricate :stage, projects: [project], compute_effort: true }
    let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }

    context 'having no blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

      it { expect(demand.blocked_working_time.to_f).to eq 0.0 }
    end
    context 'having blockings' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
      let!(:first_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 2.0, block_time: Time.zone.parse('2018-03-05 22:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:second_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:third_demand_block) { Fabricate :demand_block, demand: demand, active: false, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: Time.zone.parse('2018-03-06 13:00') }
      let!(:out_demand_block) { Fabricate :demand_block, demand: demand, active: true, block_duration: 1.0, block_time: Time.zone.parse('2018-03-06 22:00'), unblock_time: Time.zone.parse('2018-03-06 23:00') }

      it { expect(demand.blocked_working_time.to_f).to eq 3.0 }
    end
  end
end
