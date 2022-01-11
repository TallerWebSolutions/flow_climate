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
    context 'with no parameter' do
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

          expect(new_consolidations.map(&:consolidation_date)).to eq [Time.zone.today, Time.zone.today]
          expect(new_consolidations.map(&:flow_pressure)).to match_array [5.25, 3.25]
          expect(new_consolidations.map(&:customer_happiness)).to match_array [0.131578947368421, 0.131578947368421]
          expect(new_consolidations.map(&:leadtime_80)).to match_array [259_200, 172_800]
          expect(new_consolidations.map(&:max_work_in_progress)).to match_array [5, 3]
          expect(new_consolidations.map(&:montecarlo_80_percent)).to eq [7.600000000000001, 7.600000000000001]
          expect(new_consolidations.map(&:project_based_risks_to_deadline)).to match_array [0.27, 0.875]
          expect(new_consolidations.map(&:project_throughput_data)).to match_array [[0, 9, 0], [0, 0, 10, 5]]
          expect(new_consolidations.map(&:qty_selected_last_week)).to match_array [7, 9]
          expect(new_consolidations.map(&:qty_using_pressure)).to match_array [2.294117647058823, 3.705882352941176]
          expect(new_consolidations.map(&:relative_flow_pressure)).to match_array [38.23529411764706, 61.76470588235294]
          expect(new_consolidations.map(&:team_based_montecarlo_80_percent)).to eq [7.600000000000001, 7.600000000000001]
          expect(new_consolidations.map(&:team_based_odds_to_deadline)).to eq [1, 1]
          expect(new_consolidations.map(&:team_monte_carlo_weeks_max)).to eq [12, 12]
          expect(new_consolidations.map(&:team_monte_carlo_weeks_min)).to eq [8, 8]
          expect(new_consolidations.map(&:team_monte_carlo_weeks_std_dev)).to eq [2, 2]
          expect(new_consolidations.map(&:work_in_progress)).to match_array [7, 2]
        end
      end
    end

    context 'with team id as parameter' do
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
          described_class.perform_now(team.id)

          new_consolidations = Consolidations::ReplenishingConsolidation.all.order(:consolidation_date)
          expect(new_consolidations.count).to eq 2

          expect(new_consolidations.map(&:consolidation_date)).to eq [Time.zone.today, Time.zone.today]
          expect(new_consolidations.map(&:flow_pressure)).to match_array [5.25, 3.25]
          expect(new_consolidations.map(&:customer_happiness)).to match_array [0.131578947368421, 0.131578947368421]
          expect(new_consolidations.map(&:leadtime_80)).to match_array [259_200, 172_800]
          expect(new_consolidations.map(&:max_work_in_progress)).to match_array [5, 3]
          expect(new_consolidations.map(&:montecarlo_80_percent)).to eq [7.600000000000001, 7.600000000000001]
          expect(new_consolidations.map(&:project_based_risks_to_deadline)).to match_array [0.27, 0.875]
          expect(new_consolidations.map(&:project_throughput_data)).to match_array [[0, 9, 0], [0, 0, 10, 5]]
          expect(new_consolidations.map(&:qty_selected_last_week)).to match_array [7, 9]
          expect(new_consolidations.map(&:qty_using_pressure)).to match_array [2.294117647058823, 3.705882352941176]
          expect(new_consolidations.map(&:relative_flow_pressure)).to match_array [38.23529411764706, 61.76470588235294]
          expect(new_consolidations.map(&:team_based_montecarlo_80_percent)).to eq [7.600000000000001, 7.600000000000001]
          expect(new_consolidations.map(&:team_based_odds_to_deadline)).to eq [1, 1]
          expect(new_consolidations.map(&:team_monte_carlo_weeks_max)).to eq [12, 12]
          expect(new_consolidations.map(&:team_monte_carlo_weeks_min)).to eq [8, 8]
          expect(new_consolidations.map(&:team_monte_carlo_weeks_std_dev)).to eq [2, 2]
          expect(new_consolidations.map(&:work_in_progress)).to match_array [7, 2]
        end
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

  context 'with no valid team' do
    it 'does not save any and creates a log entry' do
      expect(Rails.logger).to(receive(:warn)).once
      described_class.perform_now('foo')

      new_consolidations = Consolidations::ReplenishingConsolidation.all.order(:consolidation_date)
      expect(new_consolidations.count).to eq 0
    end
  end

  context 'with projects and no project consolidations' do
    it 'saves empty consolidations' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        project = Fabricate :project, company: company, team: team, status: :executing, start_date: 3.weeks.ago, end_date: 3.days.from_now, max_work_in_progress: 5, initial_scope: 0
        other_project = Fabricate :project, company: company, team: team, status: :executing, start_date: 4.weeks.ago, end_date: 3.days.from_now, max_work_in_progress: 3, initial_scope: 0

        described_class.perform_now

        new_consolidation_project = Consolidations::ReplenishingConsolidation.where(project: project).order(:consolidation_date).first
        new_consolidation_other_project = Consolidations::ReplenishingConsolidation.where(project: other_project).order(:consolidation_date).first

        expect(new_consolidation_project.consolidation_date).to eq Time.zone.today
        expect(new_consolidation_project.flow_pressure).to eq 0
        expect(new_consolidation_project.customer_happiness).to eq 0
        expect(new_consolidation_project.leadtime_80).to eq 0
        expect(new_consolidation_project.max_work_in_progress).to eq 5
        expect(new_consolidation_project.montecarlo_80_percent).to eq 0
        expect(new_consolidation_project.project_based_risks_to_deadline).to eq 1
        expect(new_consolidation_project.project_throughput_data).to eq []
        expect(new_consolidation_project.qty_selected_last_week).to eq 0
        expect(new_consolidation_project.qty_using_pressure).to eq 0
        expect(new_consolidation_project.relative_flow_pressure).to eq 0
        expect(new_consolidation_project.team_based_montecarlo_80_percent).to eq 0
        expect(new_consolidation_project.team_based_odds_to_deadline).to eq 1
        expect(new_consolidation_project.team_monte_carlo_weeks_max).to eq 0
        expect(new_consolidation_project.team_monte_carlo_weeks_min).to eq 0
        expect(new_consolidation_project.team_monte_carlo_weeks_std_dev).to eq 0
        expect(new_consolidation_project.work_in_progress).to eq 0

        expect(new_consolidation_other_project.consolidation_date).to eq Time.zone.today
        expect(new_consolidation_other_project.flow_pressure).to eq 0
        expect(new_consolidation_other_project.customer_happiness).to eq 0
        expect(new_consolidation_other_project.leadtime_80).to eq 0
        expect(new_consolidation_other_project.max_work_in_progress).to eq 3
        expect(new_consolidation_other_project.montecarlo_80_percent).to eq 0
        expect(new_consolidation_other_project.project_based_risks_to_deadline).to eq 1
        expect(new_consolidation_other_project.project_throughput_data).to eq []
        expect(new_consolidation_other_project.qty_selected_last_week).to eq 0
        expect(new_consolidation_other_project.qty_using_pressure).to eq 0
        expect(new_consolidation_other_project.relative_flow_pressure).to eq 0
        expect(new_consolidation_other_project.team_based_montecarlo_80_percent).to eq 0
        expect(new_consolidation_other_project.team_based_odds_to_deadline).to eq 1
        expect(new_consolidation_other_project.team_monte_carlo_weeks_max).to eq 0
        expect(new_consolidation_other_project.team_monte_carlo_weeks_min).to eq 0
        expect(new_consolidation_other_project.team_monte_carlo_weeks_std_dev).to eq 0
        expect(new_consolidation_other_project.work_in_progress).to eq 0
      end
    end
  end
end
