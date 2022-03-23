# frozen_string_literal: true

RSpec.describe TasksRepository, type: :repository do
  describe '#search' do
    let(:company) { Fabricate :company }

    context 'with data' do
      it 'searches by arguments' do
        team = Fabricate :team, company: company
        other_team = Fabricate :team, company: company

        initiative = Fabricate :initiative, company: company
        other_initiative = Fabricate :initiative, company: company

        first_project = Fabricate :project, company: company, initiative: initiative, team: team
        second_project = Fabricate :project, company: company, initiative: initiative, team: other_team
        third_project = Fabricate :project, company: company, initiative: other_initiative, team: other_team

        first_demand = Fabricate :demand, company: company, project: first_project, team: team
        second_demand = Fabricate :demand, company: company, project: first_project, team: team
        third_demand = Fabricate :demand, company: company, project: second_project, team: team
        fourth_demand = Fabricate :demand, company: company, project: third_project, team: other_team

        first_task = Fabricate :task, demand: first_demand, title: 'foo BaR', created_date: 3.days.ago, end_date: 2.days.ago
        second_task = Fabricate :task, demand: second_demand, title: 'BaR', created_date: 2.days.ago, end_date: 1.day.ago
        third_task = Fabricate :task, demand: third_demand, title: 'xpTo', created_date: 1.day.ago, end_date: nil
        fourth_task = Fabricate :task, demand: fourth_demand, title: 'xpTo', created_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :task, title: 'BaR', created_date: 3.days.ago, end_date: 2.days.ago

        tasks_search = described_class.instance.search(company.id, 1, 2)
        expect(tasks_search.total_count).to eq 4
        expect(tasks_search.total_delivered_count).to eq 3
        expect(tasks_search.last_page).to be false
        expect(tasks_search.total_pages).to eq 2
        expect(described_class.instance.search(company.id, 1, 5).tasks).to match_array [first_task, second_task, third_task, fourth_task]
        expect(described_class.instance.search(company.id, 1, 5, title: 'bar').tasks).to match_array [first_task, second_task]
        expect(described_class.instance.search(company.id, 1, 5, project_id: second_project.id).tasks).to eq [third_task]
        expect(described_class.instance.search(company.id, 1, 5, initiative_id: initiative.id).tasks).to match_array [first_task, second_task, third_task]
        expect(described_class.instance.search(company.id, 1, 5, team_id: team.id).tasks).to match_array [first_task, second_task, third_task]
        expect(described_class.instance.search(company.id, 1, 5, status: 'finished').tasks).to match_array [first_task, second_task, fourth_task]
        expect(described_class.instance.search(company.id, 1, 5, status: 'not_finished').tasks).to eq [third_task]
        expect(described_class.instance.search(company.id, 1, 5, status: 'bla').tasks).to match_array [first_task, second_task, third_task, fourth_task]
        expect(described_class.instance.search(company.id, 1, 5, from_date: 2.days.ago, until_date: Time.zone.now).tasks).to match_array [second_task, third_task]
        expect(described_class.instance.search(company.id, 1, 5, from_date: 2.days.ago).tasks).to match_array [first_task, second_task, third_task, fourth_task]
        expect(described_class.instance.search(company.id, 1, 5, until_date: Time.zone.now).tasks).to match_array [first_task, second_task, third_task, fourth_task]
        expect(described_class.instance.search(company.id, 1, 5, status: 'finished', from_date: 2.days.ago, until_date: Time.zone.now).tasks).to match_array [first_task, second_task, fourth_task]
      end
    end

    context 'without data' do
      it 'returns an empty set' do
        expect(described_class.instance.search(company.id, 1, 5).tasks).to eq []
      end
    end
  end
end
