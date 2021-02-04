# frozen-string-literal: true

RSpec.describe Consolidations::ReplenishingConsolidationJob do
  let(:first_user) { Fabricate :user }

  let!(:company) { Fabricate :company, users: [first_user] }
  let(:customer) { Fabricate :customer, company: company }
  let(:team) { Fabricate :team, company: company, max_work_in_progress: 8 }

  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('consolidations')
    end
  end

  context 'with demands' do
    it 'saves the consolidations' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        project = Fabricate :project, company: company, team: team, status: :executing, start_date: 4.weeks.ago, end_date: 3.days.from_now, max_work_in_progress: 3
        other_project = Fabricate :project, company: company, team: team, status: :executing, start_date: 3.weeks.ago, end_date: 3.days.from_now, max_work_in_progress: 5
        Fabricate :project_consolidation, project: project, operational_risk: 0.875, team_based_monte_carlo_weeks_min: 8, team_based_monte_carlo_weeks_max: 12, team_based_monte_carlo_weeks_std_dev: 2
        Fabricate :project_consolidation, project: other_project, operational_risk: 0.27, team_based_monte_carlo_weeks_min: 8, team_based_monte_carlo_weeks_max: 12, team_based_monte_carlo_weeks_std_dev: 2

        5.times { Fabricate :demand, customer: customer, team: team, project: project, created_date: 10.days.ago, commitment_date: 9.days.ago, end_date: 8.days.ago, effort_downstream: 200, effort_upstream: 10 }
        2.times { Fabricate :demand, customer: customer, team: team, project: project, created_date: 5.days.ago, commitment_date: 4.days.ago, end_date: 1.day.ago, effort_downstream: 400, effort_upstream: 130 }
        7.times { Fabricate :demand, customer: customer, team: team, project: other_project, created_date: 2.days.ago, commitment_date: 1.week.ago, end_date: nil, effort_downstream: 100, effort_upstream: 20 }

        10.times { Fabricate :demand, customer: customer, team: team, project: project, created_date: 30.days.ago, commitment_date: 2.weeks.ago, end_date: 12.days.ago, effort_downstream: 200, effort_upstream: 10 }
        9.times { Fabricate :demand, customer: customer, team: team, project: other_project, created_date: 20.days.ago, commitment_date: 19.days.ago, end_date: 16.days.ago, effort_downstream: 400, effort_upstream: 130 }
        2.times { Fabricate :demand, customer: customer, team: team, project: project, created_date: 7.days.ago, commitment_date: 1.week.ago, end_date: nil, effort_downstream: 100, effort_upstream: 20 }

        allow(Stats::StatisticsService.instance).to(receive(:run_montecarlo)).and_return([4, 3, 6, 10])
        described_class.perform_now

        new_consolidations = Consolidations::ReplenishingConsolidation.all.order(:consolidation_date)
        expect(new_consolidations.count).to eq 2

        expect(new_consolidations[0].consolidation_date).to eq Time.zone.today
        expect(new_consolidations[0].flow_pressure).to eq 3.05454545454546
        expect(new_consolidations[0].customer_happiness).to eq 0.131578947368421
        expect(new_consolidations[0].leadtime_80).to eq 259_200
        expect(new_consolidations[0].max_work_in_progress).to eq 5
        expect(new_consolidations[0].montecarlo_80_percent).to eq 7.6
        expect(new_consolidations[0].project_based_risks_to_deadline).to eq 0.27
        expect(new_consolidations[0].project_throughput_data).to eq [0, 9, 0]
        expect(new_consolidations[0].qty_selected_last_week).to eq 7
        expect(new_consolidations[0].qty_using_pressure).to eq 3.36
        expect(new_consolidations[0].relative_flow_pressure).to eq 56
        expect(new_consolidations[0].team_based_montecarlo_80_percent).to eq 7.6
        expect(new_consolidations[0].team_based_odds_to_deadline).to eq 1
        expect(new_consolidations[0].team_monte_carlo_weeks_max).to eq 12
        expect(new_consolidations[0].team_monte_carlo_weeks_min).to eq 8
        expect(new_consolidations[0].team_monte_carlo_weeks_std_dev).to eq 2
        expect(new_consolidations[0].work_in_progress).to eq 7

        expect(new_consolidations[1].consolidation_date).to eq Time.zone.today
        expect(new_consolidations[1].flow_pressure).to eq 2.40000000000001
        expect(new_consolidations[1].customer_happiness).to eq 0.131578947368421
        expect(new_consolidations[1].leadtime_80).to eq 172_800
        expect(new_consolidations[1].max_work_in_progress).to eq 3
        expect(new_consolidations[1].montecarlo_80_percent).to eq 7.6
        expect(new_consolidations[1].project_based_risks_to_deadline).to eq 0.875
        expect(new_consolidations[1].project_throughput_data).to eq [0, 0, 10, 5]
        expect(new_consolidations[1].qty_selected_last_week).to eq 9
        expect(new_consolidations[1].qty_using_pressure).to eq 2.64
        expect(new_consolidations[1].relative_flow_pressure).to eq 44
        expect(new_consolidations[1].team_based_montecarlo_80_percent).to eq 7.6
        expect(new_consolidations[1].team_based_odds_to_deadline).to eq 1
        expect(new_consolidations[1].team_monte_carlo_weeks_max).to eq 12
        expect(new_consolidations[1].team_monte_carlo_weeks_min).to eq 8
        expect(new_consolidations[1].team_monte_carlo_weeks_std_dev).to eq 2
        expect(new_consolidations[1].work_in_progress).to eq 2
      end
    end
  end

  context 'with no projects' do
    it 'saves no consolidations' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        described_class.perform_now

        new_consolidations = Consolidations::ReplenishingConsolidation.all.order(:consolidation_date)
        expect(new_consolidations.count).to eq 0
      end
    end
  end

  context 'with projects and no project consolidations' do
    it 'saves empty consolidations' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        Fabricate :project, company: company, team: team, status: :executing, start_date: 4.weeks.ago, end_date: 3.days.from_now, max_work_in_progress: 3, initial_scope: 0
        Fabricate :project, company: company, team: team, status: :executing, start_date: 3.weeks.ago, end_date: 3.days.from_now, max_work_in_progress: 5, initial_scope: 0

        described_class.perform_now

        new_consolidations = Consolidations::ReplenishingConsolidation.all.order(:consolidation_date)
        expect(new_consolidations.count).to eq 2

        expect(new_consolidations[0].consolidation_date).to eq Time.zone.today
        expect(new_consolidations[0].flow_pressure).to eq 0
        expect(new_consolidations[0].customer_happiness).to eq 0
        expect(new_consolidations[0].leadtime_80).to eq 0
        expect(new_consolidations[0].max_work_in_progress).to eq 5
        expect(new_consolidations[0].montecarlo_80_percent).to eq 0
        expect(new_consolidations[0].project_based_risks_to_deadline).to eq 1
        expect(new_consolidations[0].project_throughput_data).to eq []
        expect(new_consolidations[0].qty_selected_last_week).to eq 0
        expect(new_consolidations[0].qty_using_pressure).to eq 0
        expect(new_consolidations[0].relative_flow_pressure).to eq 0
        expect(new_consolidations[0].team_based_montecarlo_80_percent).to eq 0
        expect(new_consolidations[0].team_based_odds_to_deadline).to eq 1
        expect(new_consolidations[0].team_monte_carlo_weeks_max).to eq 0
        expect(new_consolidations[0].team_monte_carlo_weeks_min).to eq 0
        expect(new_consolidations[0].team_monte_carlo_weeks_std_dev).to eq 0
        expect(new_consolidations[0].work_in_progress).to eq 0

        expect(new_consolidations[1].consolidation_date).to eq Time.zone.today
        expect(new_consolidations[1].flow_pressure).to eq 0
        expect(new_consolidations[1].customer_happiness).to eq 0
        expect(new_consolidations[1].leadtime_80).to eq 0
        expect(new_consolidations[1].max_work_in_progress).to eq 3
        expect(new_consolidations[1].montecarlo_80_percent).to eq 0
        expect(new_consolidations[1].project_based_risks_to_deadline).to eq 1
        expect(new_consolidations[1].project_throughput_data).to eq []
        expect(new_consolidations[1].qty_selected_last_week).to eq 0
        expect(new_consolidations[1].qty_using_pressure).to eq 0
        expect(new_consolidations[1].relative_flow_pressure).to eq 0
        expect(new_consolidations[1].team_based_montecarlo_80_percent).to eq 0
        expect(new_consolidations[1].team_based_odds_to_deadline).to eq 1
        expect(new_consolidations[1].team_monte_carlo_weeks_max).to eq 0
        expect(new_consolidations[1].team_monte_carlo_weeks_min).to eq 0
        expect(new_consolidations[1].team_monte_carlo_weeks_std_dev).to eq 0
        expect(new_consolidations[1].work_in_progress).to eq 0
      end
    end
  end
end
