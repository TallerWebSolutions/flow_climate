# frozen_string_literal: true

RSpec.describe ProjectResultsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

  let!(:first_project) { Fabricate :project, customer: customer, product: product, start_date: Time.iso8601('2018-01-09T23:01:46'), end_date: Time.iso8601('2018-03-16T23:01:46') }
  let!(:second_project) { Fabricate :project, customer: customer, product: product, start_date: Time.iso8601('2018-01-10T23:01:46'), end_date: Time.iso8601('2018-03-16T23:01:46') }
  let!(:third_project) { Fabricate :project, customer: customer, product: product, start_date: Time.iso8601('2018-01-04T23:01:46'), end_date: Time.iso8601('2018-03-16T23:01:46') }

  let!(:stage) { Fabricate :stage, projects: [first_project], integration_id: '2481595', compute_effort: true }
  let!(:end_stage) { Fabricate :stage, projects: [first_project], integration_id: '2481597', compute_effort: false, end_point: true }

  describe '#project_results_for_company_month' do
    let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-01-11T23:01:46'), qty_hours_downstream: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.project_results_for_company_month(company, Time.iso8601('2018-02-14T23:01:46').month, Time.iso8601('2018-02-14T23:01:46').year)).to match_array [first_result, second_result] }
  end

  describe '#consumed_hours_in_week' do
    let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.consumed_hours_in_week(company, Time.iso8601('2018-02-14T23:01:46').to_date.cweek, Time.iso8601('2018-02-14T23:01:46').to_date.cwyear)).to eq 80 }
  end

  describe '#th_in_week_for_company' do
    let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-14T23:01:46'), throughput: 30 }
    let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-14T23:01:46'), throughput: 50 }
    let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), throughput: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), throughput: 60 }

    it { expect(ProjectResultsRepository.instance.th_in_week_for_company(company, Time.iso8601('2018-02-14T23:01:46').to_date.cweek, Time.iso8601('2018-02-14T23:01:46').to_date.cwyear)).to eq 80 }
  end

  describe '#bugs_opened_in_week' do
    let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_opened: 30 }
    let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_opened: 50 }
    let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), qty_bugs_opened: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_opened: 60 }

    it { expect(ProjectResultsRepository.instance.bugs_opened_in_week(company, Time.iso8601('2018-02-14T23:01:46').to_date.cweek, Time.iso8601('2018-02-14T23:01:46').to_date.cwyear)).to eq 80 }
  end

  describe '#bugs_closed_in_week' do
    let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 30 }
    let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 50 }
    let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), qty_bugs_closed: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

    it { expect(ProjectResultsRepository.instance.bugs_closed_in_week(company, Time.iso8601('2018-02-14T23:01:46').to_date.cweek, Time.iso8601('2018-02-14T23:01:46').to_date.cwyear)).to eq 80 }
  end

  describe '#scope_in_week_for_project' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46') }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-15T23:01:46') }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46') }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([first_project], Time.iso8601('2018-02-14T23:01:46').to_date.cweek, Time.iso8601('2018-02-14T23:01:46').to_date.cwyear)).to eq first_result.known_scope }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-11T23:01:46') }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([first_project], Time.iso8601('2018-02-15T23:01:46').to_date.cweek, Time.iso8601('2018-02-15T23:01:46').to_date.cwyear)).to eq first_result.known_scope }
    end
    context 'when there is no data' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46'), known_scope: 30 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-03-25T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([first_project], Time.iso8601('2018-02-15T23:01:46').to_date.cweek, Time.iso8601('2018-02-15T23:01:46').to_date.cwyear)).to eq first_project.initial_scope }
    end
  end

  describe '#flow_pressure_in_week_for_projects' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46'), flow_pressure: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-15T23:01:46'), flow_pressure: 10 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), flow_pressure: 5 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([first_project])).to eq(Time.iso8601('2018-02-16T23:01:46').localtime(0).change(hour: 0).beginning_of_week => 0.2e2) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([project])).to eq({}) }
    end
  end

  describe '#throughput_for_projects_grouped_per_week' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46'), throughput: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-15T23:01:46'), throughput: 10 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), throughput: 5 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week([first_project, second_project])).to eq(Time.iso8601('2018-02-16T23:01:46-00:00').change(hour: 0).beginning_of_week => 30) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week([project])).to eq({}) }
    end
  end

  describe '#hours_per_demand_in_time_for_projects' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46'), throughput: 20, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-16T23:01:46'), throughput: 10, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), throughput: 5, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([first_project, second_project])).to eq(Time.iso8601('2018-02-16T23:01:46').localtime(0).change(hour: 0).beginning_of_week => 2.066666666666667) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([project])).to eq({}) }
    end
  end

  pending '#delivered_until_week'

  describe '#average_demand_cost_in_week_for_projects' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46'), throughput: 20, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 100 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.iso8601('2018-02-16T23:01:46'), throughput: 10, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 150 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.iso8601('2018-02-11T23:01:46'), throughput: 5, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 50 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.iso8601('2018-02-14T23:01:46'), flow_pressure: 4, cost_in_month: 300 }

      it { expect(ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects([first_project, second_project])).to eq(Time.iso8601('2018-02-16T23:01:46').localtime(0).change(hour: 0).beginning_of_week => 1.0416666666666667) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects([project])).to eq({}) }
    end
  end

  describe '#update_result_for_date' do
    context 'having the project_result' do
      let!(:result) { Fabricate :project_result, project: first_project, result_date: Time.iso8601('2018-02-16T23:01:46'), throughput: 20, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 340 }

      context 'having demands for the date' do
        let!(:first_demand) { Fabricate :demand, project: first_project, demand_type: :feature, project_result: result, effort: 100 }
        let!(:second_demand) { Fabricate :demand, project: first_project, demand_type: :bug, project_result: result, effort: 123 }
        let!(:third_demand) { Fabricate :demand, project: first_project, demand_type: :feature, project_result: result, effort: 12 }
        let!(:first_transition) { Fabricate :demand_transition, stage: end_stage, demand: first_demand, last_time_in: '2018-02-16T01:01:41-02:00', last_time_out: '2018-02-18T01:01:41-02:00' }
        let!(:second_transition) { Fabricate :demand_transition, stage: end_stage, demand: second_demand, last_time_in: '2018-02-16T01:01:41-02:00', last_time_out: '2018-02-16T01:42:41-02:00' }
        let!(:third_transition) { Fabricate :demand_transition, stage: stage, demand: third_demand, last_time_in: '2018-02-10T01:01:41-02:00' }

        it 'updates the project result' do
          ProjectResultsRepository.instance.update_result_for_date(first_project, Date.new(2018, 2, 16))
          updated_project_result = ProjectResult.last
          expect(updated_project_result.project).to eq first_project
          expect(updated_project_result.result_date).to eq Time.iso8601('2018-02-16T23:01:46').to_date
          expect(updated_project_result.known_scope).to eq 3
          expect(updated_project_result.throughput).to eq 2
          expect(updated_project_result.qty_hours_upstream).to eq 0
          expect(updated_project_result.qty_hours_downstream).to eq 223
          expect(updated_project_result.qty_hours_bug).to eq 123
          expect(updated_project_result.qty_bugs_closed).to eq 1
          expect(updated_project_result.qty_bugs_opened).to eq 1
          expect(updated_project_result.flow_pressure.to_f).to eq 0.0714285714285714
          expect(updated_project_result.remaining_days).to eq 28
          expect(updated_project_result.average_demand_cost.to_f).to eq 5.666666666666667
        end
      end

      context 'having no demands for the date' do
        it 'updates the project result' do
          ProjectResultsRepository.instance.update_result_for_date(first_project, Time.iso8601('2018-02-16T23:01:46'))
          updated_project_result = ProjectResult.last
          expect(updated_project_result.project).to eq first_project
          expect(updated_project_result.result_date).to eq Time.iso8601('2018-02-16T23:01:46').to_date
          expect(updated_project_result.known_scope).to eq 0
          expect(updated_project_result.throughput).to eq 0
          expect(updated_project_result.qty_hours_upstream).to eq 0
          expect(updated_project_result.qty_hours_downstream).to eq 0
          expect(updated_project_result.qty_hours_bug).to eq 0
          expect(updated_project_result.qty_bugs_closed).to eq 0
          expect(updated_project_result.qty_bugs_opened).to eq 0
          expect(updated_project_result.flow_pressure.to_f).to eq 0
          expect(updated_project_result.remaining_days).to eq 28
          expect(updated_project_result.average_demand_cost.to_f).to eq 0
        end
      end
    end

    context 'having no project_result' do
      it 'returns doing nothing' do
        ProjectResultsRepository.instance.update_result_for_date(first_project, Time.iso8601('2018-02-16T23:01:46'))
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
      before { ProjectResultsRepository.instance.create_project_result(project, team, Time.iso8601('2018-02-15T23:01:46')) }
      it { expect(ProjectResult.count).to eq 1 }
    end
    context 'when there is project result to the date' do
      let!(:project_result) { Fabricate :project_result, project: project, result_date: Time.iso8601('2018-02-15T23:01:46') }
      before { ProjectResultsRepository.instance.create_project_result(project, team, Time.iso8601('2018-02-15T23:01:46')) }
      it { expect(ProjectResult.count).to eq 1 }
    end
    context 'when there is project result to other date' do
      let!(:project_result) { Fabricate :project_result, project: project, result_date: Time.iso8601('2018-02-14T23:01:46').to_date }
      before { ProjectResultsRepository.instance.create_project_result(project, team, Time.iso8601('2018-02-15T23:01:46')) }
      it { expect(ProjectResult.count).to eq 2 }
    end
  end

  pending '#update_all_results'
end
