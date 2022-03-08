# frozen-string-literal: true

RSpec.describe DemandEffortService, type: :service do
  describe '#build_efforts_to_demand' do
    let(:company) { Fabricate :company }
    let(:project) { Fabricate :project, company: company }
    let(:team) { Fabricate :team, company: company }
    let(:demand) { Fabricate :demand, team: team, project: project }
    let(:stage) { Fabricate :stage, company: company, stage_stream: :upstream }
    let(:other_stage) { Fabricate :stage, company: company, stage_stream: :downstream }

    context 'with one assignment matching the transition' do
      it 'builds a demand_effort to the demand' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 2.4
        expect(DemandEffort.all.sum(&:effort_with_blocks)).to eq 2.4
        expect(DemandEffort.all.sum(&:total_blocked)).to eq 0
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

    context 'with one assignment starting before the transition end time and finishing in another transition' do
      it 'builds two demand_efforts one for each transition' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: other_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        team_member = Fabricate :team_member, company: demand.company
        membership = Fabricate :membership, team_member: team_member, team: demand.team

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 20:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-24 21:51'), last_time_out: Time.zone.parse('2021-05-24 22:51')
        Fabricate :item_assignment, demand: demand, membership: membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 16:51')
        Fabricate :item_assignment, demand: demand, membership: membership, start_time: Time.zone.parse('2021-05-24 17:51'), finish_time: Time.zone.parse('2021-05-24 19:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(7.1)
        expect(demand.reload.effort_upstream).to be_within(0.1).of(7.1)
        expect(demand.reload.effort_downstream).to eq 0
        expect(demand.reload.effort_development).to be_within(0.1).of(7.1)
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with blocked time in the transition' do
      it 'builds the demand efforts removing the time blocked' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: other_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-26 12:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-26 12:51'), last_time_out: Time.zone.parse('2021-05-27 15:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 20:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-25 10:51'), finish_time: Time.zone.parse('2021-05-25 15:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-24 12:51'), unblock_time: Time.zone.parse('2021-05-24 14:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-24 13:52'), unblock_time: Time.zone.parse('2021-05-24 19:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-25 14:52'), unblock_time: Time.zone.parse('2021-05-25 15:52')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.map(&:effort_value).map(&:to_f)).to eq [0.0, 4.8]
        expect(DemandEffort.all.map(&:total_blocked).map(&:to_f)).to eq [7.199999999999999, 1.2]
        expect(DemandEffort.all.map(&:effort_with_blocks).map(&:to_f)).to eq [7.199999999999999, 6.0]
        expect(demand.reload.effort_upstream.to_f).to eq 4.8
        expect(demand.reload.effort_downstream.to_f).to eq 0
        expect(demand.reload.effort_development.to_f).to eq 4.8
        expect(demand.reload.effort_design.to_f).to eq 0
        expect(demand.reload.effort_management.to_f).to eq 0
      end
    end

    context 'with drop offs and a full day of effort' do
      it 'builds the correct effort data' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-28 12:51')

        team_member = Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'bar', name: 'team_member'
        other_team_member = Fabricate :team_member, company: company, name: 'other_team_member'
        membership = Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil
        other_membership = Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil

        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:51')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 11:52'), finish_time: Time.zone.parse('2021-05-24 12:52')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 12:53'), finish_time: Time.zone.parse('2021-05-24 13:53')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 13:54'), finish_time: Time.zone.parse('2021-05-24 14:54')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 14:55'), finish_time: Time.zone.parse('2021-05-24 15:55')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 15:56'), finish_time: Time.zone.parse('2021-05-24 16:56')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 16:57'), finish_time: Time.zone.parse('2021-05-25 10:57')
        Fabricate :item_assignment, membership: other_membership, demand: demand, start_time: Time.zone.parse('2021-05-24 12:53'), finish_time: nil

        allow(Time.zone).to(receive(:now)).and_return(Time.zone.local(2021, 5, 25, 10, 58, 0))
        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 10
        expect(DemandEffort.all.sum(&:effort_value).to_f).to eq 20.4
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
        expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(5.9)
        expect(demand.reload.effort_upstream).to eq previous_effort_upstream
        expect(demand.reload.effort_downstream).to eq previous_effort_downstream
      end
    end

    context 'with holidays' do
      it 'does not create demand_effort' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-28 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-28 11:11')
        Fabricate :flow_event, team: team, event_type: :day_off, event_date: Time.zone.parse('2021-05-24 11:11'), event_end_date: Time.zone.parse('2021-05-25 11:11')
        Fabricate :flow_event, team: team, event_type: :api_not_ready, event_date: Time.zone.parse('2021-05-27 11:11'), event_end_date: Time.zone.parse('2021-05-28 11:11')
        Fabricate :flow_event, team: team, event_type: :day_off, event_date: Time.zone.parse('2021-05-22 11:11'), event_end_date: Time.zone.parse('2021-05-23 11:11')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 5
        expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(27.5)
        expect(DemandEffort.all.sum(&:effort_with_blocks)).to be_within(0.1).of(27.5)
        expect(DemandEffort.all.sum(&:total_blocked)).to eq 0
        expect(demand.reload.effort_development).to be_within(0.1).of(27.5)
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end
  end
end
