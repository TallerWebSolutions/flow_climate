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
    pending '.opened_in_date'
    pending '.finished'
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
        it { expect(demand.effort.to_f).to eq 5.0 }
      end
      context 'having blockings' do
        let(:demand) { Fabricate :demand, project: project, assignees_count: 1 }
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 2.0 }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0 }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 2.0 }
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
        it { expect(demand.effort.to_f).to eq 7.5 }
      end
      context 'having blockings' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: effort_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
        let!(:first_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 2.0 }
        let!(:second_demand_block) { Fabricate :demand_block, demand: demand, block_duration: 1.0 }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 3.0 }
      end

      context 'having no transition in the effort stage' do
        let!(:demand_transition) { Fabricate :demand_transition, demand: demand, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }

        before { demand.update_effort! }
        it { expect(demand.effort.to_f).to eq 0.0 }
      end
    end
  end
end
