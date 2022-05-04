# frozen_string_literal: true

RSpec.describe DemandTransitionsRepository, type: :repository do
  describe '#summed_transitions_time_grouped_by_stage_demand_for' do
    context 'with data' do
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

    context 'with no data' do
      it { expect(described_class.instance.summed_transitions_time_grouped_by_stage_demand_for(Demand.all)).to eq({}) }
    end
  end
end
