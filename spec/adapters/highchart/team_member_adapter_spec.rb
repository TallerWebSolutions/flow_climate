# frozen_string_literal: true

RSpec.describe Highchart::TeamMemberAdapter do
  let(:company) { Fabricate :company }
  let(:team) { Fabricate :team, company: company }

  context 'with data' do
    it 'builds the hours per project data structure' do
      travel_to Time.zone.local(2021, 12, 1, 10, 0, 0) do
        first_project = Fabricate :project, company: company, start_date: 4.months.ago, end_date: 1.month.from_now
        second_project = Fabricate :project, company: company, start_date: 4.months.ago, end_date: 1.month.from_now
        third_project = Fabricate :project, company: company, start_date: 4.months.ago, end_date: 1.month.from_now

        team_member = Fabricate :team_member, company: company, name: 'ddd', start_date: 4.months.ago, end_date: nil
        first_membership = Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 3.months.ago, end_date: nil
        Fabricate :membership, team: team, team_member: team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago

        first_demand = Fabricate :demand, team: team, project: first_project, commitment_date: 4.months.ago, end_date: 3.months.ago
        second_demand = Fabricate :demand, team: team, project: second_project, commitment_date: 3.months.ago, end_date: 3.weeks.ago
        third_demand = Fabricate :demand, team: team, project: first_project, commitment_date: 2.months.ago, end_date: 1.month.ago
        fourth_demand = Fabricate :demand, team: team, project: third_project, commitment_date: 1.month.ago, end_date: 3.days.ago
        fifth_demand = Fabricate :demand, team: team, project: third_project, commitment_date: 9.weeks.ago, end_date: 2.weeks.ago
        sixth_demand = Fabricate :demand, team: team, commitment_date: 9.days.ago, end_date: nil

        first_assignment = Fabricate :item_assignment, demand: first_demand, membership: first_membership
        second_assignment = Fabricate :item_assignment, demand: second_demand, membership: first_membership
        third_assignment = Fabricate :item_assignment, demand: third_demand, membership: first_membership
        fourth_assignment = Fabricate :item_assignment, demand: fourth_demand, membership: first_membership
        other_membership_assignment = Fabricate :item_assignment, demand: fifth_demand
        Fabricate :item_assignment, demand: sixth_demand, membership: first_membership

        Fabricate :demand_effort, demand: first_demand, item_assignment: first_assignment, start_time_to_computation: 65.days.ago, effort_value: 10
        Fabricate :demand_effort, demand: first_demand, item_assignment: second_assignment, start_time_to_computation: 64.days.ago, effort_value: 20
        Fabricate :demand_effort, demand: second_demand, item_assignment: third_assignment, start_time_to_computation: 37.days.ago, effort_value: 30
        Fabricate :demand_effort, demand: fourth_demand, item_assignment: fourth_assignment, start_time_to_computation: 25.days.ago, effort_value: 100
        Fabricate :demand_effort, demand: fourth_demand, item_assignment: other_membership_assignment, start_time_to_computation: 22.days.ago, effort_value: 204

        team_member_chart_adapter = described_class.new(team_member)

        expect(team_member_chart_adapter.team_member).to eq team_member
        expect(team_member_chart_adapter.x_axis_hours_per_project).to eq [3.months.ago.end_of_month, 2.months.ago.end_of_month, 1.month.ago.end_of_month, Time.zone.now.end_of_month].map(&:to_date)
        expect(team_member_chart_adapter.y_axis_hours_per_project).to match_array [{ data: [30.0, 0.0, 0.0, 0.0], name: first_project.name }, { data: [0.0, 30.0, 0.0, 0.0], name: second_project.name }, { data: [0.0, 0.0, 100.0, 0.0], name: third_project.name }]
      end
    end
  end
end
