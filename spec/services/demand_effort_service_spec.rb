# frozen-string-literal: true

RSpec.describe DemandEffortService, type: :service do
  describe '#build_efforts_to_demand' do
    let(:project) { Fabricate :project }
    let(:demand) { Fabricate :demand, project: project }
    let(:stage) { Fabricate :stage, stage_stream: :upstream }
    let(:other_stage) { Fabricate :stage, stage_stream: :downstream }

    context 'with one assignment matching the transition' do
      it 'builds a demand_effort to the demand' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 2.4
        expect(demand.reload.effort_development).to eq 2.4
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one assignment starting before the transition start time' do
      it 'builds a demand_effort to the demand using the transition start date' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 09:51'), finish_time: Time.zone.parse('2021-05-24 12:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 1
        expect(DemandEffort.all.sum(&:effort_value)).to eq 2.4
        expect(demand.reload.effort_development).to eq 2.4
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one assignment starting after the transition start time' do
      it 'builds a demand_effort to the demand using the assignment start date' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 11:51'), finish_time: Time.zone.parse('2021-05-24 12:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 1
        expect(DemandEffort.all.sum(&:effort_value)).to eq 1.2
        expect(demand.reload.effort_development).to eq 1.2
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one assignment ending after the transition end time' do
      it 'builds a demand_effort to the demand using the transition end date' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 13:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 1
        expect(DemandEffort.all.sum(&:effort_value)).to eq 2.4
        expect(demand.reload.effort_development).to eq 2.4
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one assignment ending before the transition end time' do
      it 'builds a demand_effort to the demand using the assignment end date' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 1
        expect(DemandEffort.all.sum(&:effort_value)).to eq 1.2
        expect(demand.reload.effort_development).to eq 1.2
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one assignment ending before the transition end time and finishing in another transition' do
      it 'builds two demand_efforts one for each transition' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: other_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-24 12:51'), last_time_out: Time.zone.parse('2021-05-24 15:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 6
        expect(demand.reload.effort_upstream).to eq 2.4
        expect(demand.reload.effort_downstream).to eq 3.6
        expect(demand.reload.effort_development).to eq 6
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with blocked time in the transition' do
      it 'builds the demand efforts removing the time blocked' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: other_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-24 12:51'), last_time_out: Time.zone.parse('2021-05-24 15:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-24 13:51'), unblock_time: Time.zone.parse('2021-05-24 14:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-24 11:51'), unblock_time: Time.zone.parse('2021-05-24 12:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 3.599999999999999
        expect(DemandEffort.all.sum(&:total_blocked)).to eq 2.4
        expect(demand.reload.effort_upstream).to eq 1.2
        expect(demand.reload.effort_downstream).to eq 2.399999999999999
        expect(demand.reload.effort_development).to eq 3.599999999999999
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with manual effort in demand' do
      it 'builds the demand efforts but keeps the manual effort pre-defined' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: other_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-24 12:51'), last_time_out: Time.zone.parse('2021-05-24 15:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 15:51')

        previous_effort_upstream = demand.effort_upstream
        previous_effort_downstream = demand.effort_downstream
        demand.update(manual_effort: true)

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 6.0
        expect(demand.reload.effort_upstream).to eq previous_effort_upstream
        expect(demand.reload.effort_downstream).to eq previous_effort_downstream
      end
    end
  end
end
