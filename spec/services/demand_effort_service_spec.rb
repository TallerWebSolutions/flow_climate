# frozen_string_literal: true

RSpec.describe DemandEffortService, type: :service do
  let(:company) { Fabricate :company }
  let(:project) { Fabricate :project, company: company }
  let(:other_project) { Fabricate :project, company: company }
  let(:team) { Fabricate :team, company: company }
  let(:demand) { Fabricate :demand, team: team, project: project }
  let(:stage) { Fabricate :stage, company: company, stage_stream: :upstream }
  let(:other_stage) { Fabricate :stage, company: company, stage_stream: :downstream }

  describe '#build_efforts_to_demand' do
    context 'with one assignment matching the transition' do
      context 'for not discarded demands' do
        it 'builds a demand_effort to the demand' do
          travel_to Time.zone.local(2022, 3, 14, 10, 0, 0) do
            dev_membership = Fabricate :membership, member_role: :developer
            other_dev_membership = Fabricate :membership, member_role: :developer
            client_membership = Fabricate :membership, member_role: :client

            Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
            Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
            Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
            Fabricate :item_assignment, demand: demand, membership: other_dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')
            Fabricate :item_assignment, demand: demand, membership: client_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')

            described_class.instance.build_efforts_to_demand(demand)

            expect(DemandEffort.all.count).to eq 2
            expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(2.5)
            expect(DemandEffort.all.sum(&:total_blocked)).to eq 0
            expect(demand.reload.effort_development).to be_within(0.1).of(2.5)
            expect(demand.reload.effort_design).to eq 0
            expect(demand.reload.effort_management).to eq 0
          end
        end
      end

      context 'for discarded demands' do
        it 'builds a demand_effort to the demand' do
          travel_to Time.zone.local(2022, 3, 14, 10, 0, 0) do
            demand.update(discarded_at: Time.zone.local(2021, 5, 24, 11, 51))
            dev_membership = Fabricate :membership, member_role: :developer
            other_dev_membership = Fabricate :membership, member_role: :developer
            client_membership = Fabricate :membership, member_role: :client

            Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
            Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
            Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
            Fabricate :item_assignment, demand: demand, membership: other_dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')
            Fabricate :item_assignment, demand: demand, membership: client_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')

            described_class.instance.build_efforts_to_demand(demand)

            expect(DemandEffort.all.count).to eq 2
            expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(1.3)
            expect(DemandEffort.all.sum(&:total_blocked)).to eq 0
            expect(demand.reload.effort_development).to be_within(0.1).of(1.3)
            expect(demand.reload.effort_design).to eq 0
            expect(demand.reload.effort_management).to eq 0
          end
        end
      end
    end

    context 'with one assignment starting before the transition start time' do
      it 'builds a demand_effort to the demand using the transition start date' do
        dev_membership = Fabricate :membership, member_role: :developer
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 09:51'), finish_time: Time.zone.parse('2021-05-24 12:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 1
        expect(DemandEffort.all.sum(&:effort_value)).to eq 2.4
        expect(demand.reload.effort_development).to eq 2.4
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one previous effort with 8h' do
      it 'builds a zero value effort' do
        dev_membership = Fabricate :membership, member_role: :developer
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 50, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 08:00'), last_time_out: Time.zone.parse('2021-05-24 20:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 08:00'), finish_time: Time.zone.parse('2021-05-24 16:30')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 17:01'), finish_time: Time.zone.parse('2021-05-24 18:00')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 9
        expect(demand.reload.effort_development).to eq 9
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with one assignment starting after the transition start time' do
      it 'builds a demand_effort to the demand using the assignment start date' do
        dev_membership = Fabricate :membership, member_role: :developer
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 11:51'), finish_time: Time.zone.parse('2021-05-24 12:51')

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
        dev_membership = Fabricate :membership, member_role: :developer
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 13:51')

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
        dev_membership = Fabricate :membership, member_role: :developer
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:51')

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
        membership = Fabricate :membership, team_member: team_member, team: demand.team, member_role: :developer

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 20:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-24 21:51'), last_time_out: Time.zone.parse('2021-05-24 22:51')
        Fabricate :item_assignment, demand: demand, membership: membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 16:51')
        Fabricate :item_assignment, demand: demand, membership: membership, start_time: Time.zone.parse('2021-05-24 17:51'), finish_time: Time.zone.parse('2021-05-24 19:51')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(9.5)
        expect(demand.reload.effort_upstream).to be_within(0.1).of(9.5)
        expect(demand.reload.effort_downstream).to eq 0
        expect(demand.reload.effort_development).to be_within(0.1).of(9.5)
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with blocked time in the transition' do
      it 'builds the demand efforts removing the time blocked' do
        dev_membership = Fabricate :membership, member_role: :developer
        other_dev_membership = Fabricate :membership, member_role: :developer

        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: other_stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-26 12:51')
        Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-26 12:51'), last_time_out: Time.zone.parse('2021-05-27 15:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 20:51')
        Fabricate :item_assignment, demand: demand, membership: other_dev_membership, start_time: Time.zone.parse('2021-05-25 10:51'), finish_time: Time.zone.parse('2021-05-25 15:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-24 12:51'), unblock_time: Time.zone.parse('2021-05-24 14:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-24 13:52'), unblock_time: Time.zone.parse('2021-05-24 19:51')
        Fabricate :demand_block, demand: demand, block_time: Time.zone.parse('2021-05-25 14:52'), unblock_time: Time.zone.parse('2021-05-25 15:52')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.map { |effort| effort.effort_value.to_f }).to eq [2.56, 4.819999999999999]
        expect(DemandEffort.all.map { |effort| effort.total_blocked.to_f }).to eq [7.016666666666667, 0.9833333333333333]
        expect(demand.reload.effort_upstream.to_f).to eq 7.379999999999999
        expect(demand.reload.effort_downstream.to_f).to eq 0
        expect(demand.reload.effort_development.to_f).to eq 7.379999999999999
        expect(demand.reload.effort_design.to_f).to eq 0
        expect(demand.reload.effort_management.to_f).to eq 0
      end
    end

    context 'with drop offs and a full day of effort' do
      it 'builds the correct effort data' do
        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :stage_project_config, stage: stage, project: other_project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50

        other_project_demand = Fabricate :demand, team: team, project: other_project

        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-28 17:51')
        Fabricate :demand_transition, demand: other_project_demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-28 12:51')

        team_member = Fabricate :team_member, company: company, jira_account_user_email: 'foo', jira_account_id: 'bar', name: 'team_member'
        other_team_member = Fabricate :team_member, company: company, name: 'other_team_member'
        membership = Fabricate :membership, team: team, team_member: team_member, member_role: :developer, hours_per_month: 120, start_date: 1.month.ago, end_date: nil
        other_membership = Fabricate :membership, team: team, team_member: other_team_member, member_role: :developer, hours_per_month: 120, start_date: 1.month.ago, end_date: nil

        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:51')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 11:52'), finish_time: Time.zone.parse('2021-05-24 12:52')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 12:53'), finish_time: Time.zone.parse('2021-05-24 13:53')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 13:54'), finish_time: Time.zone.parse('2021-05-24 14:54')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 14:55'), finish_time: Time.zone.parse('2021-05-24 15:55')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 15:56'), finish_time: Time.zone.parse('2021-05-24 16:56')
        Fabricate :item_assignment, membership: membership, demand: demand, start_time: Time.zone.parse('2021-05-24 16:57'), finish_time: Time.zone.parse('2021-05-25 10:57')
        Fabricate :item_assignment, membership: membership, demand: other_project_demand, start_time: Time.zone.parse('2021-05-24 14:52'), finish_time: Time.zone.parse('2021-05-24 16:30')
        Fabricate :item_assignment, membership: membership, demand: other_project_demand, start_time: Time.zone.parse('2021-05-24 16:52'), finish_time: Time.zone.parse('2021-05-24 18:30')

        Fabricate :item_assignment, membership: other_membership, demand: demand, start_time: Time.zone.parse('2021-05-24 00:00'), finish_time: Time.zone.parse('2021-05-24 16:35')
        Fabricate :item_assignment, membership: other_membership, demand: demand, start_time: Time.zone.parse('2021-05-24 17:55'), finish_time: Time.zone.parse('2021-05-24 23:59')

        allow(Time.zone).to(receive(:now)).and_return(Time.zone.local(2021, 5, 25, 10, 58, 0))
        described_class.instance.build_efforts_to_demand(demand)
        described_class.instance.build_efforts_to_demand(other_project_demand)

        expect(demand.demand_efforts.all.map { |effort| effort.effort_value.to_f }).to match_array [6.88, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 3.659999999999999, 3.54, 2.5]
        expect(demand.demand_efforts.sum(&:effort_value).to_f).to eq 20.18

        expect(other_project_demand.demand_efforts.all.map { |effort| effort.effort_value.to_f }).to eq [1.96, 1.96]
        expect(other_project_demand.demand_efforts.sum(&:effort_value).to_f).to eq 3.92
      end
    end

    context 'with holidays' do
      it 'does not create demand_effort' do
        dev_membership = Fabricate :membership, member_role: :developer
        other_dev_membership = Fabricate :membership, member_role: :developer

        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 20, pairing_percentage: 50
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-28 12:51')
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
        Fabricate :item_assignment, demand: demand, membership: other_dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-28 11:11')
        Fabricate :flow_event, team: team, event_type: :day_off, event_date: Time.zone.parse('2021-05-24 11:11'), event_end_date: Time.zone.parse('2021-05-25 11:11')
        Fabricate :flow_event, team: team, event_type: :api_not_ready, event_date: Time.zone.parse('2021-05-27 11:11'), event_end_date: Time.zone.parse('2021-05-28 11:11')
        Fabricate :flow_event, team: team, event_type: :day_off, event_date: Time.zone.parse('2021-05-22 11:11'), event_end_date: Time.zone.parse('2021-05-23 11:11')

        described_class.instance.build_efforts_to_demand(demand)

        expect(DemandEffort.all.count).to eq 3
        expect(DemandEffort.all.sum(&:effort_value)).to be_within(0.1).of(18.21)
        expect(DemandEffort.all.sum(&:total_blocked)).to eq 0
        expect(demand.reload.effort_development).to be_within(0.1).of(18.21)
        expect(demand.reload.effort_design).to eq 0
        expect(demand.reload.effort_management).to eq 0
      end
    end

    context 'with efforts in the edges of the day' do
      it 'computes the correct times' do
        dev_membership = Fabricate :membership, member_role: :developer

        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 0, pairing_percentage: 0
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.local(2022, 12, 5, 18, 29), last_time_out: Time.zone.local(2022, 12, 6, 10, 45)
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.local(2022, 12, 5, 18, 30), finish_time: Time.zone.local(2022, 12, 6, 10, 46)

        described_class.instance.build_efforts_to_demand(demand)
        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 4.25
      end
    end

    context 'with efforts passing the day but not completing 24h' do
      it 'computes the correct times' do
        dev_membership = Fabricate :membership, member_role: :developer

        Fabricate :stage_project_config, stage: stage, project: project, compute_effort: true, stage_percentage: 100, management_percentage: 0, pairing_percentage: 0
        Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.local(2022, 12, 5, 11, 29), last_time_out: Time.zone.local(2022, 12, 6, 10, 45)
        Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.local(2022, 12, 5, 11, 30), finish_time: Time.zone.local(2022, 12, 6, 10, 46)

        described_class.instance.build_efforts_to_demand(demand)
        expect(DemandEffort.all.count).to eq 2
        expect(DemandEffort.all.sum(&:effort_value)).to eq 8.75
      end
    end
  end

  describe '#update_demand_effort_caches' do
    it 'computes the effort cached based on the demand efforts' do
      dev_membership = Fabricate :membership, member_role: :developer
      other_dev_membership = Fabricate :membership, member_role: :developer

      first_transition = Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
      second_transition = Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.parse('2021-05-24 10:51'), last_time_out: Time.zone.parse('2021-05-24 12:51')
      first_assignment = Fabricate :item_assignment, demand: demand, membership: dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 12:51')
      second_assignment = Fabricate :item_assignment, demand: demand, membership: other_dev_membership, start_time: Time.zone.parse('2021-05-24 10:51'), finish_time: Time.zone.parse('2021-05-24 11:11')

      Fabricate :demand_effort, demand: demand, item_assignment: first_assignment, effort_value: 10, demand_transition: first_transition
      Fabricate :demand_effort, demand: demand, item_assignment: second_assignment, effort_value: 20, demand_transition: second_transition

      described_class.instance.update_demand_effort_caches(demand)

      expect(demand.reload.effort_upstream).to eq 10
      expect(demand.reload.effort_downstream).to eq 20
      expect(demand.reload.effort_development).to eq 30
      expect(demand.reload.effort_design).to eq 0
      expect(demand.reload.effort_management).to eq 0
    end
  end
end
