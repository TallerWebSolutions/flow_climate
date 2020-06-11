# frozen_string_literal: true

RSpec.describe Flow::MembershipFlowInformation, type: :service do
  describe '#compute_developer_effort' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    let!(:project) { Fabricate :project, company: company }

    let(:first_stage) { Fabricate :stage, company: company, teams: [team], stage_type: :development, queue: false }
    let(:second_stage) { Fabricate :stage, company: company, teams: [team], stage_type: :development, queue: false }
    let(:third_stage) { Fabricate :stage, company: company, teams: [team], stage_type: :analysis, queue: false, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: project, stage: first_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: project, stage: second_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: project, stage: third_stage, compute_effort: false, pairing_percentage: 0, stage_percentage: 0, management_percentage: 0 }

    let(:team_member) { Fabricate :team_member, company: company, start_date: 40.days.ago }
    let(:other_team_member) { Fabricate :team_member, company: company }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, start_date: 1.year.ago, end_date: nil, member_role: :developer }
    let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, start_date: 4.months.ago, end_date: 1.month.ago, member_role: :developer }

    let!(:first_delivered_demand) { Fabricate :demand, team: team, project: project, company: company, created_date: 45.days.ago, commitment_date: 44.weeks.ago, end_date: 40.days.ago }
    let!(:demand) { Fabricate :demand, team: team, project: project, company: company, created_date: 45.days.ago }

    let!(:first_demand_transtion) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: 40.days.ago, last_time_out: 27.days.ago }
    let!(:second_demand_transtion) { Fabricate :demand_transition, demand: demand, stage: second_stage, last_time_in: 7.days.ago, last_time_out: 1.day.ago }
    let!(:third_demand_transtion) { Fabricate :demand_transition, demand: demand, stage: third_stage, last_time_in: 5.days.ago, last_time_out: 4.days.ago }

    let!(:item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: 39.days.ago, finish_time: 27.days.ago }
    let!(:other_item_assignment) { Fabricate :item_assignment, demand: demand, team_member: team_member, start_time: 7.days.ago, finish_time: 1.day.ago }

    let!(:demand_block) { Fabricate :demand_block, demand: demand, block_time: 35.days.ago, unblock_time: 34.days.ago }
    let!(:other_demand_block) { Fabricate :demand_block, demand: demand, block_time: 38.days.ago, unblock_time: nil }

    context 'with demands' do
      it 'compute the effort for the developer' do
        travel_to Time.zone.local(2020, 6, 9, 15, 41, 52) do
          allow_any_instance_of(Membership).to(receive(:demands)).and_return(Demand.all)
          membership_flow = described_class.new(membership)

          expect(membership_flow.compute_developer_effort).to eq [53, 24]
        end
      end
    end

    context 'with no demands' do
      it 'returns zero' do
        allow_any_instance_of(Membership).to(receive(:demands)).and_return(Demand.all)
        membership_flow = described_class.new(other_membership)

        expect(membership_flow.compute_developer_effort).to eq [0, 0]
      end
    end
  end
end
