# frozen_string_literal: true

RSpec.describe TasksRepository, type: :repository do
  describe '#search' do
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company }

    context 'with data' do
      it 'searches by arguments' do
        team = Fabricate :team, company: company
        other_team = Fabricate :team, company: company

        initiative = Fabricate :initiative, company: company
        other_initiative = Fabricate :initiative, company: company

        first_project = Fabricate :project, company: company, initiative: initiative, team: team
        second_project = Fabricate :project, company: company, initiative: initiative, team: other_team
        third_project = Fabricate :project, company: company, initiative: other_initiative, team: other_team

        parent_unit = Fabricate :portfolio_unit, product: product, name: 'Registration'
        other_parent_unit = Fabricate :portfolio_unit, product: product, name: 'Charts'
        portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'Registration Unit', parent: parent_unit
        other_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'Project Charts', parent: other_parent_unit

        first_demand = Fabricate :demand, company: company, project: first_project, team: team, portfolio_unit: portfolio_unit
        second_demand = Fabricate :demand, company: company, project: first_project, team: team, portfolio_unit: portfolio_unit
        third_demand = Fabricate :demand, company: company, project: second_project, team: team, portfolio_unit: parent_unit
        fourth_demand = Fabricate :demand, company: company, project: third_project, team: other_team, portfolio_unit: other_portfolio_unit

        work_item_type = Fabricate :work_item_type, company: company, name: 'OOH', item_level: :task
        other_work_item_type = Fabricate :work_item_type, company: company, name: 'bbb', item_level: :task

        first_task = Fabricate :task, demand: first_demand, work_item_type: work_item_type, title: 'foo BaR', created_date: 3.days.ago, end_date: 2.days.ago
        second_task = Fabricate :task, demand: second_demand, work_item_type: work_item_type, title: 'BaR', created_date: 2.days.ago, end_date: 1.day.ago
        third_task = Fabricate :task, demand: third_demand, work_item_type: other_work_item_type, title: 'xpTo', created_date: 1.day.ago, end_date: nil
        fourth_task = Fabricate :task, demand: fourth_demand, work_item_type: other_work_item_type, title: 'xpTo bleh', created_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :task, title: 'BaR', created_date: 3.days.ago, end_date: 2.days.ago, work_item_type: other_work_item_type

        tasks_search = described_class.instance.search(company.id, 1, 2, { portfolio_unit_name: 'rEGistration' })
        expect(tasks_search.total_count).to eq 3
        expect(tasks_search.total_delivered_count).to eq 2
        expect(tasks_search.last_page).to be false
        expect(tasks_search.total_pages).to eq 2
        expect(tasks_search.tasks).to eq [third_task, second_task]

        expect(described_class.instance.search(company.id, 1, 3).tasks).to match_array [second_task, third_task, fourth_task]
        expect(described_class.instance.search(company.id, 1).tasks).to match_array [first_task, second_task, third_task, fourth_task]
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
        expect(described_class.instance.search(company.id, 1, 5, task_type: 'ooh').tasks).to match_array [first_task, second_task]
      end
    end

    context 'without data' do
      it 'returns an empty set' do
        expect(described_class.instance.search(company.id, 1, 5).tasks).to eq []
      end
    end

    context 'invalid limit' do
      it 'returns an empty set' do
        expect(described_class.instance.search(company.id, 5, 0).tasks).to eq []
      end
    end
  end
end
