# frozen_string_literal: true

RSpec.describe ProjectResultsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

  describe '#project_results_for_company_month' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 1.month.ago, end_date: 1.month.from_now, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_downstream: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.project_results_for_company_month(company, 1.day.ago.month, 1.day.ago.year)).to match_array [first_result, second_result] }
  end

  describe '#consumed_hours_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_upstream: 0, qty_hours_downstream: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.consumed_hours_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#th_in_week_for_company' do
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, throughput: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, throughput: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 60 }

    it { expect(ProjectResultsRepository.instance.th_in_week_for_company(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#th_in_week_for_project' do
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, throughput: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, throughput: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 60 }

    it { expect(ProjectResultsRepository.instance.th_in_week_for_projects([project], 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 30 }
  end

  describe '#bugs_opened_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_bugs_opened: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_bugs_opened: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_bugs_opened: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_opened: 60 }

    it { expect(ProjectResultsRepository.instance.bugs_opened_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#bugs_closed_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_bugs_closed: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_bugs_closed: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_bugs_closed: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60 }

    it { expect(ProjectResultsRepository.instance.bugs_closed_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#scope_in_week_for_project' do
    context 'when there is data in the week' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, qty_bugs_closed: 30 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, qty_bugs_closed: 50 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_bugs_closed: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([project], 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq first_result.known_scope }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 3.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, qty_bugs_closed: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq first_result.known_scope }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.from_now, qty_bugs_closed: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq project.initial_scope }
    end
  end

  describe '#flow_pressure_in_week_for_projects' do
    context 'when there is data in the week' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.week.ago, flow_pressure: 20 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: Time.zone.today, flow_pressure: 10 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, flow_pressure: 5 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq 20.0 }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, qty_bugs_closed: 90, flow_pressure: 4 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60, flow_pressure: 3 }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 4 }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.from_now, flow_pressure: 3 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
  end

  describe '#throughput_in_week_for_projects' do
    context 'when there is data in the week' do
      let!(:first_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:second_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:third_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }

      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, throughput: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago, throughput: 10 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: 2.months.ago, throughput: 5 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.throughput_in_week_for_projects([first_project, second_project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq 30 }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, throughput: 4 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 3 }

      it { expect(ProjectResultsRepository.instance.throughput_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.from_now, throughput: 3 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 4 }

      it { expect(ProjectResultsRepository.instance.throughput_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
  end

  describe '#throughput_in_week_for_projects' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    context 'when there is data in the week' do
      let!(:first_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:second_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:third_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }

      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, throughput: 20, average_demand_cost: 20, cost_in_month: 11 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago, throughput: 10, average_demand_cost: 20, cost_in_month: 11 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: 2.months.ago, throughput: 5, average_demand_cost: 20, cost_in_month: 11 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.throughput_in_week_for_projects([first_project, second_project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq 30 }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, throughput: 4 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 3 }

      it { expect(ProjectResultsRepository.instance.throughput_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.from_now, throughput: 3 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 4 }

      it { expect(ProjectResultsRepository.instance.throughput_in_week_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
  end

  describe '#hours_per_demand_in_time_for_projects' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    context 'when there is data in the week' do
      let!(:first_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:second_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
      let!(:third_project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }

      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago, throughput: 20, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago, throughput: 10, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: 2.months.ago, throughput: 5, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([first_project, second_project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq 2.325 }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, throughput: 4 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 3 }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.month.from_now, throughput: 3 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 4 }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([project], Time.zone.today.cweek, Time.zone.today.cwyear)).to eq 0 }
    end
  end

  describe '#update_result_for_date' do
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 2.months.ago, end_date: 3.weeks.from_now }
    context 'having the project_result' do
      let!(:result) { Fabricate :project_result, project: project, result_date: 1.week.ago, throughput: 20, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 340 }

      context 'having no demands for the date' do
        it 'updates the project result' do
          ProjectResultsRepository.instance.update_result_for_date(project, 1.week.ago, 20, 5)
          updated_project_result = ProjectResult.last
          expect(updated_project_result.project).to eq project
          expect(updated_project_result.result_date).to eq 1.week.ago.to_date
          expect(updated_project_result.known_scope).to eq 20
          expect(updated_project_result.throughput).to eq 0
          expect(updated_project_result.qty_hours_upstream).to eq 0
          expect(updated_project_result.qty_hours_downstream).to eq 0
          expect(updated_project_result.qty_hours_bug).to eq 0
          expect(updated_project_result.qty_bugs_closed).to eq 0
          expect(updated_project_result.qty_bugs_opened).to eq 5
          expect(updated_project_result.flow_pressure.to_f).to eq 0.0
          expect(updated_project_result.remaining_days).to eq 28
          expect(updated_project_result.average_demand_cost.to_f).to eq 0
        end
      end

      context 'having demands for the date' do
        let!(:demand) { Fabricate :demand, demand_type: :feature, project_result: result, end_date: 1.week.ago.to_date, effort: 100 }

        it 'updates the project result' do
          ProjectResultsRepository.instance.update_result_for_date(project, 1.week.ago, 20, 5)
          updated_project_result = ProjectResult.last
          expect(updated_project_result.project).to eq project
          expect(updated_project_result.result_date).to eq 1.week.ago.to_date
          expect(updated_project_result.known_scope).to eq 20
          expect(updated_project_result.throughput).to eq 1
          expect(updated_project_result.qty_hours_upstream).to eq 0
          expect(updated_project_result.qty_hours_downstream).to eq 100
          expect(updated_project_result.qty_hours_bug).to eq 0
          expect(updated_project_result.qty_bugs_closed).to eq 0
          expect(updated_project_result.qty_bugs_opened).to eq 5
          expect(updated_project_result.flow_pressure.to_f).to eq 0.0357142857142857
          expect(updated_project_result.remaining_days).to eq 28
          expect(updated_project_result.average_demand_cost.to_f).to eq 11.333333333333334
        end
      end
    end

    context 'having no project_result' do
      it 'returns doing nothing' do
        ProjectResultsRepository.instance.update_result_for_date(project, 1.week.ago, 20, 5)
        expect(ProjectResult.count).to eq 0
      end
    end
  end

  describe '#create_project_result' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }

    context 'when there is no project result to the date' do
      before { ProjectResultsRepository.instance.create_project_result(project, team, Time.zone.today) }
      it { expect(ProjectResult.count).to eq 1 }
    end
    context 'when there is project result to the date' do
      let!(:project_result) { Fabricate :project_result, project: project, result_date: Time.zone.today }
      before { ProjectResultsRepository.instance.create_project_result(project, team, Time.zone.today) }
      it { expect(ProjectResult.count).to eq 1 }
    end
    context 'when there is project result to other date' do
      let!(:project_result) { Fabricate :project_result, project: project, result_date: 1.day.ago.to_date }
      before { ProjectResultsRepository.instance.create_project_result(project, team, Time.zone.today) }
      it { expect(ProjectResult.count).to eq 2 }
    end
  end
end
