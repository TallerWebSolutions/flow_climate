# frozen_string_literal: true

RSpec.describe DemandTransitionsRepository, type: :repository do
  describe '#summed_transitions_time_grouped_by_stage_demand_for' do
    context 'having data' do
      let(:company) { Fabricate :company }

      let(:first_project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

      let(:first_stage) { Fabricate :stage, company: company, projects: [first_project], integration_pipe_id: '123', order: 0, stage_stream: :upstream }
      let(:second_stage) { Fabricate :stage, company: company, projects: [first_project], integration_pipe_id: '123', order: 1, stage_stream: :upstream, end_point: true }

      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: Time.zone.now, external_id: 'CAVM-1977' }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: nil }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: nil }

      let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-02-28T17:09:58-03:00' }
      let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: '2018-02-20T17:09:58-03:00', last_time_out: '2018-02-23T17:09:58-03:00' }
      let!(:third_transition) { Fabricate :demand_transition, stage: second_stage, demand: third_demand, last_time_in: '2018-04-04T17:09:58-03:00', last_time_out: nil }

      it { expect(described_class.instance.summed_transitions_time_grouped_by_stage_demand_for(Demand.all)).to eq(first_stage.name => { data: { first_demand.external_id => 1.day.to_f }, consolidation: 1.day.to_f }, second_stage.name => { data: { second_demand.external_id => 259_200.0, third_demand.external_id => nil }, consolidation: 259_200.0 }) }
    end

    context 'having no data' do
      it { expect(described_class.instance.summed_transitions_time_grouped_by_stage_demand_for(Demand.all)).to eq({}) }
    end
  end

  describe '#hours_per_stage' do
    context 'with transitions' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customers: [customer] }
      let(:other_project) { Fabricate :project, customers: [customer] }

      it 'returns the hours per stage based on the search' do
        first_stage = Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'first_stage', queue: false, order: 2, stage_level: :coordination
        second_stage = Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'second_stage', queue: false, order: 1, parent: first_stage, stage_level: :team
        fourth_stage = Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, name: 'fourth_stage', queue: false, order: 0, stage_level: :team

        third_stage = Fabricate :stage, company: company, projects: [other_project], stage_stream: :downstream, name: 'third_stage', queue: true, order: 4, stage_level: :team
        fifth_stage = Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'fifth_stage', queue: true, order: 3, parent: first_stage, stage_level: :team

        sixth_stage = Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'sixth_stage', end_point: true, order: 5, stage_level: :team

        seventh_stage = Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, name: 'seventh_stage', end_point: false, order: 5, stage_level: :team

        demand = Fabricate :demand, project: project
        other_demand = Fabricate :demand, project: other_project

        Fabricate :demand_transition, stage: first_stage, demand: demand, last_time_in: '2018-02-27T17:09:58-03:00', last_time_out: '2018-03-02T17:09:58-03:00'
        Fabricate :demand_transition, stage: second_stage, demand: demand, last_time_in: '2018-02-02T17:09:58-03:00', last_time_out: '2018-02-09T17:09:58-03:00'
        Fabricate :demand_transition, stage: fourth_stage, demand: demand, last_time_in: '2018-01-08T17:09:58-03:00', last_time_out: '2018-02-02T17:09:58-03:00'

        Fabricate :demand_transition, stage: third_stage, demand: other_demand, last_time_in: '2018-04-02T17:09:58-03:00', last_time_out: '2018-05-15T17:09:58-03:00'
        Fabricate :demand_transition, stage: fifth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00'

        Fabricate :demand_transition, stage: sixth_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: '2018-04-02T17:09:58-03:00'

        Fabricate :demand_transition, stage: seventh_stage, demand: demand, last_time_in: '2018-03-08T17:09:58-03:00', last_time_out: nil

        expect(described_class.instance.hours_per_stage(Project.all, :upstream, :team, Date.new(2018, 1, 1))).to eq([['fourth_stage', 2_160_000.0]])
        expect(described_class.instance.hours_per_stage(Project.all, :upstream, :team, Date.new(2018, 2, 2))).to eq([])
        expect(described_class.instance.hours_per_stage(Project.all, :downstream, :team, Date.new(2018, 1, 1))).to eq([['second_stage', 604_800.0], ['fifth_stage', 2_160_000.0], ['third_stage', 3_715_200.0]])
        expect(described_class.instance.hours_per_stage(Project.all, :downstream, :team, Date.new(2018, 2, 2))).to eq([['second_stage', 604_800.0], ['fifth_stage', 2_160_000.0], ['third_stage', 3_715_200.0]])
        expect(described_class.instance.hours_per_stage(Project.all, :downstream, :coordination, Date.new(2018, 2, 2))).to eq([['second_stage', 604_800.0], ['first_stage', 259_200.0], ['fifth_stage', 2_160_000.0], ['third_stage', 3_715_200.0]])
      end
    end

    context 'having no transitions' do
      it { expect(described_class.instance.hours_per_stage(Project.all, :upstream, :team, Date.new(2018, 1, 1))).to eq [] }
    end
  end
end
