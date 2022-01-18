# frozen_string_literal: true

RSpec.describe Dashboards::OperationsDashboardCacheJob do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('dashboards')
    end
  end

  context 'with valid data' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    it 'generates the dashboard cache' do
      travel_to Time.zone.local(2020, 9, 29, 13, 0, 0) do
        customer = Fabricate :customer, company: company
        product = Fabricate :product, company: company, customer: customer
        project = Fabricate :project, products: [product], team: team, company: company
        analysis_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'analysis_stage', commitment_point: false, end_point: false, queue: false, stage_type: :analysis
        commitment_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'commitment_stage', commitment_point: true, end_point: false, queue: false, stage_type: :development
        end_stage = Fabricate :stage, company: company, projects: [project], teams: [team], name: 'end_stage', commitment_point: false, end_point: true, queue: false, stage_type: :development
        first_team_member = Fabricate :team_member, company: company, name: 'first_member'
        second_team_member = Fabricate :team_member, company: company, name: 'second_member'
        first_membership = Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer, end_date: nil
        second_membership = Fabricate :membership, team: team, team_member: second_team_member, member_role: :developer, end_date: nil
        first_demand = Fabricate :demand, company: company, team: team, project: project
        second_demand = Fabricate :demand, company: company, team: team, project: project
        third_demand = Fabricate :demand, company: company, team: team, project: project

        Fabricate :demand_transition, stage: commitment_stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 5.days.ago
        Fabricate :demand_transition, stage: commitment_stage, demand: second_demand, last_time_in: 6.days.ago, last_time_out: 4.days.ago
        Fabricate :demand_transition, stage: commitment_stage, demand: third_demand, last_time_in: 96.hours.ago, last_time_out: 95.hours.ago

        Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: 5.days.ago, last_time_out: 1.minute.ago
        Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: 4.days.ago, last_time_out: 2.days.ago
        Fabricate :demand_transition, stage: end_stage, demand: third_demand, last_time_in: 95.hours.ago, last_time_out: 94.hours.ago
        Fabricate :demand_transition, stage: analysis_stage, demand: first_demand, last_time_in: 120.hours.ago, last_time_out: 105.hours.ago

        Fabricate :item_assignment, membership: first_membership, demand: first_demand, start_time: 4.days.ago, finish_time: 1.day.ago
        Fabricate :item_assignment, membership: first_membership, demand: second_demand, start_time: 3.days.ago, finish_time: 1.day.ago
        Fabricate :item_assignment, membership: second_membership, demand: first_demand, start_time: 4.days.ago, finish_time: 1.day.ago
        Fabricate :item_assignment, membership: second_membership, demand: second_demand, start_time: 3.days.ago, finish_time: 1.day.ago

        described_class.perform_now(first_team_member, first_team_member.start_date, Time.zone.today)

        expect(Dashboards::OperationsDashboard.count).to eq 3
        expect(Dashboards::OperationsDashboard.last.lead_time_p80).to eq 380_160
        expect(Dashboards::OperationsDashboard.last.delivered_demands_count).to eq 2

        expect(Dashboards::OperationsDashboardPairing.count).to eq 3
      end
    end
  end

  context 'with no demands data' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }

    it 'generates an empty dashboard cache' do
      travel_to Time.zone.local(2020, 9, 29, 13, 0, 0) do
        first_team_member = Fabricate :team_member, company: company, name: 'first_member'

        Fabricate :membership, team: team, team_member: first_team_member, member_role: :developer

        described_class.perform_now(first_team_member, first_team_member.start_date, Time.zone.today)

        expect(Dashboards::OperationsDashboard.count).to eq 3
        expect(Dashboards::OperationsDashboard.last.lead_time_p80).to eq 0

        expect(Dashboards::OperationsDashboardPairing.count).to eq 0
      end
    end
  end
end
