# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_type).with(feature: 0, bug: 1, performance_improvement: 2, ux_improvement: 3, chore: 4) }
    it { is_expected.to define_enum_for(:class_of_service).with(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :project_result }
    it { is_expected.to have_many :demand_transitions }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :demand_id }
    it { is_expected.to validate_presence_of :demand_type }
    it { is_expected.to validate_presence_of :class_of_service }
  end

  context 'scopes' do
    pending '.bugs_opened_until_date_count'
    pending '.finished_until_date'
    pending '.created_until_date'

    describe '.known_scope_to_date' do
      let!(:project) { Fabricate :project, initial_scope: 100, start_date: 2.months.ago, end_date: 1.month.from_now }

      let!(:stage) { Fabricate :stage, projects: [project], compute_effort: true }
      let!(:end_stage) { Fabricate :stage, projects: [project], compute_effort: false, end_point: true }
      let!(:first_demand) { Fabricate :demand, project: project, demand_type: :feature }
      let!(:second_demand) { Fabricate :demand, project: project, demand_type: :bug }
      let!(:third_demand) { Fabricate :demand, project: project, demand_type: :feature }
      let!(:first_transition) { Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: '2018-02-16T01:01:41-02:00', last_time_out: '2018-02-18T01:01:41-02:00' }
      let!(:second_transition) { Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: '2018-02-16T01:01:41-02:00', last_time_out: '2018-02-16T01:42:41-02:00' }
      let!(:third_transition) { Fabricate :demand_transition, stage: stage, demand: third_demand, last_time_in: '2018-02-10T01:01:41-02:00' }

      context 'having demands created until the date' do
        it { expect(Demand.known_scope_to_date(Date.new(2018, 2, 16))).to eq 3 }
      end
      context 'having no demands created until the date' do
        it { expect(Demand.known_scope_to_date(Date.new(2018, 1, 1))).to eq 0 }
      end
    end
  end
end
