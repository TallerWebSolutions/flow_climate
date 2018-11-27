# frozen_string_literal: true

RSpec.describe ProjectTeamCostUpdateWeeklyJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      ProjectTeamCostUpdateWeeklyJob.perform_later
      expect(ProjectTeamCostUpdateWeeklyJob).to have_been_enqueued.on_queue('default')
    end
  end

  context 'having projects' do
    let!(:first_project) { Fabricate :project, status: :executing }
    let!(:second_project) { Fabricate :project, status: :cancelled }
    let!(:third_project) { Fabricate :project, status: :waiting }
    let!(:fourth_project) { Fabricate :project, status: :finished }
    let!(:fifth_project) { Fabricate :project, status: :maintenance }
    let!(:sixth_project) { Fabricate :project, status: :negotiating }

    context 'having no weekly cost to this week' do
      it 'collects a new cost to the week' do
        ProjectTeamCostUpdateWeeklyJob.perform_now
        expect(ProjectWeeklyCost.count).to eq 1
        expect(ProjectWeeklyCost.first.date_beggining_of_week).to eq Date.commercial(Time.zone.today.cwyear, Time.zone.today.cweek, 1)
        expect(ProjectWeeklyCost.first.project).to eq first_project
        expect(ProjectWeeklyCost.first.monthly_cost_value).to eq first_project.current_cost
      end
    end
    context 'having weekly cost to this week' do
      let!(:project_weekly_cost) { Fabricate :project_weekly_cost, date_beggining_of_week: Date.commercial(Time.zone.today.cwyear, Time.zone.today.cweek, 1), project: first_project, monthly_cost_value: 200 }
      it 'does not duplicate the cost and just updates the value' do
        ProjectTeamCostUpdateWeeklyJob.perform_now
        expect(ProjectWeeklyCost.count).to eq 1
        expect(ProjectWeeklyCost.first.monthly_cost_value).to eq first_project.current_cost
      end
    end
    context 'having weekly cost to other week' do
      let!(:project_weekly_cost) { Fabricate :project_weekly_cost, date_beggining_of_week: Date.commercial(1.week.ago.to_date.cwyear, 1.week.ago.to_date.cweek, 1), project: first_project, monthly_cost_value: 200 }
      it 'does not duplicate the cost and just updates the value' do
        ProjectTeamCostUpdateWeeklyJob.perform_now
        expect(ProjectWeeklyCost.count).to eq 2
      end
    end
  end
end
