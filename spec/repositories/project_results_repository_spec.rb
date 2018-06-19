# frozen_string_literal: true

RSpec.describe ProjectResultsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

  let!(:first_project) { Fabricate :project, customer: customer, product: product, start_date: Time.zone.iso8601('2018-01-03T23:01:46'), end_date: Time.zone.iso8601('2018-03-16T23:01:46') }
  let!(:second_project) { Fabricate :project, customer: customer, product: product, start_date: Time.zone.iso8601('2018-01-10T23:01:46'), end_date: Time.zone.iso8601('2018-03-16T23:01:46') }
  let!(:third_project) { Fabricate :project, customer: customer, product: product, start_date: Time.zone.iso8601('2018-01-04T23:01:46'), end_date: Time.zone.iso8601('2018-03-16T23:01:46') }

  let!(:stage) { Fabricate :stage, integration_id: '2481595' }
  let!(:end_stage) { Fabricate :stage, integration_id: '2481597', end_point: true }

  let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: stage, compute_effort: true }
  let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: end_stage, compute_effort: false }

  describe '#project_results_for_company_month' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 60 }

      it { expect(ProjectResultsRepository.instance.project_results_for_company_month(company, Time.zone.iso8601('2018-02-14T23:01:46'))).to match_array [second_result, third_result] }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.project_results_for_company_month(company, Time.zone.iso8601('2018-02-14T23:01:46'))).to eq [] }
    end
  end

  describe '#consumed_hours_in_month' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 60 }

      it { expect(ProjectResultsRepository.instance.consumed_hours_in_month(company, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 140 }
    end
    context 'having no results' do
      it {  expect(ProjectResultsRepository.instance.consumed_hours_in_month(company, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#consumed_hours_in_week' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 60 }

      it { expect(ProjectResultsRepository.instance.consumed_hours_in_week([first_project, second_project, third_project])).to eq [[2018.0, 2.0, 30], [2018.0, 6.0, 90], [2018.0, 7.0, 50]] }
    end
    context 'having no results' do
      it {  expect(ProjectResultsRepository.instance.consumed_hours_in_week([first_project, second_project, third_project])).to eq [] }
    end
  end

  describe '#consumed_hours_in_month' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_hours_upstream: 0, qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_hours_downstream: 60 }

      it { expect(ProjectResultsRepository.instance.consumed_hours_in_month(company, Time.zone.iso8601('2018-02-14T23:01:46'))).to eq 140 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.consumed_hours_in_month(company, Time.zone.iso8601('2018-02-14T23:01:46'))).to eq 0 }
    end
  end

  describe '#upstream_throughput_in_month_for_company' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), throughput_upstream: 30, throughput_downstream: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), throughput_upstream: 50, throughput_downstream: 40 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), throughput_upstream: 90, throughput_downstream: 70 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), throughput_upstream: 60 }

      it { expect(ProjectResultsRepository.instance.upstream_throughput_in_month_for_company(company, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 140 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.upstream_throughput_in_month_for_company(company, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#downstream_throughput_in_month_for_company' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), throughput_upstream: 30, throughput_downstream: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), throughput_upstream: 50, throughput_downstream: 40 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), throughput_upstream: 90, throughput_downstream: 70 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), throughput_downstream: 60 }

      it { expect(ProjectResultsRepository.instance.downstream_throughput_in_month_for_company(company, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 110 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.downstream_throughput_in_month_for_company(company, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#bugs_opened_in_month' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), qty_bugs_opened: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_opened: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_bugs_opened: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_opened: 60 }

      it { expect(ProjectResultsRepository.instance.bugs_opened_in_month(company.projects, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 140 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.bugs_opened_in_month(company.projects, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#bugs_closed_in_month' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-14T23:01:46'), qty_bugs_closed: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_bugs_closed: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.bugs_closed_in_month(company.projects, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 140 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.bugs_closed_in_month(company.projects, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#bugs_opened_in_week' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-08T23:01:46'), qty_bugs_opened: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-01-10T23:01:46'), qty_bugs_opened: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-01-15T23:01:46'), qty_bugs_opened: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_opened: 60 }

      it { expect(ProjectResultsRepository.instance.bugs_opened_in_week(company.projects, Time.zone.iso8601('2018-01-09T23:01:46').to_date)).to eq 80 }
      it { expect(ProjectResultsRepository.instance.bugs_opened_in_week(company.projects, Time.zone.iso8601('2018-01-16T23:01:46').to_date)).to eq 90 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.bugs_opened_in_week(company.projects, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#bugs_closed_per_week' do
    context 'having results' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-01-08T23:01:46'), qty_bugs_closed: 30 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-01-10T23:01:46'), qty_bugs_closed: 50 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-01-15T23:01:46'), qty_bugs_closed: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.bugs_closed_in_week(company.projects, Time.zone.iso8601('2018-01-09T23:01:46').to_date)).to eq 80 }
      it { expect(ProjectResultsRepository.instance.bugs_closed_in_week(company.projects, Time.zone.iso8601('2018-01-16T23:01:46').to_date)).to eq 90 }
    end
    context 'having no results' do
      it { expect(ProjectResultsRepository.instance.bugs_closed_in_week(company.projects, Time.zone.iso8601('2018-02-14T23:01:46').to_date)).to eq 0 }
    end
  end

  describe '#scope_in_week_for_project' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46') }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46') }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46') }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([first_project], Time.zone.iso8601('2018-02-14T23:01:46').to_date.cweek, Time.zone.iso8601('2018-02-14T23:01:46').to_date.cwyear)).to eq first_result.known_scope }
    end
    context 'when there is no data in the week but there is in past weeks' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46') }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([first_project], Time.zone.iso8601('2018-02-15T23:01:46').to_date.cweek, Time.zone.iso8601('2018-02-15T23:01:46').to_date.cwyear)).to eq first_result.known_scope }
    end
    context 'when there is no data' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), known_scope: 30 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-03-25T23:01:46'), qty_bugs_closed: 60 }

      it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([first_project], Time.zone.iso8601('2018-02-15T23:01:46').to_date.cweek, Time.zone.iso8601('2018-02-15T23:01:46').to_date.cwyear)).to eq first_project.initial_scope }
    end
  end

  describe '#flow_pressure_in_week_for_projects' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), flow_pressure: 20 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46'), flow_pressure: 10 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), flow_pressure: 5 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([first_project])).to eq(Time.zone.iso8601('2018-02-16T23:01:46').localtime(0).change(hour: 0).beginning_of_week => 0.2e2) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.flow_pressure_in_week_for_projects([project])).to eq({}) }
    end
  end

  describe '#throughput_for_projects_grouped_per_week' do
    context 'when the data is for upstream' do
      context 'when there is data in the week' do
        let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), throughput_upstream: 20 }
        let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46'), throughput_upstream: 10 }
        let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), throughput_upstream: 5 }
        let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

        it { expect(ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week([first_project, second_project], :upstream)).to eq(Time.iso8601('2018-02-16T23:01:46-00:00').utc.change(hour: 0).beginning_of_week => 30) }
      end
      context 'when there is no data' do
        let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

        it { expect(ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week([project], :upstream)).to eq({}) }
      end
    end
    context 'when the data is for downstream' do
      context 'when there is data in the week' do
        let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), throughput_downstream: 20 }
        let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46'), throughput_downstream: 10 }
        let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), throughput_downstream: 5 }
        let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

        it { expect(ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week([first_project, second_project], :downstream)).to eq(Time.iso8601('2018-02-16T23:01:46-00:00').utc.change(hour: 0).beginning_of_week => 30) }
      end
      context 'when there is no data' do
        let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

        it { expect(ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week([project], :downstream)).to eq({}) }
      end
    end
  end

  describe '#hours_per_demand_in_time_for_projects' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), throughput_upstream: 20, throughput_downstream: 10, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), throughput_upstream: 10, throughput_downstream: 5, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), throughput_upstream: 5, throughput_downstream: 7, qty_hours_downstream: 20, qty_hours_upstream: 11 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([first_project, second_project])).to eq(Time.zone.iso8601('2018-02-16T23:01:46').localtime(0).change(hour: 0).beginning_of_week => 4.133333333333334) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects([project])).to eq({}) }
    end
  end

  describe '#average_demand_cost_in_week_for_projects' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), throughput_upstream: 20, throughput_downstream: 10, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 100 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), throughput_upstream: 10, throughput_downstream: 5, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 150 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), throughput_upstream: 5, throughput_downstream: 7, qty_hours_downstream: 20, qty_hours_upstream: 11, cost_in_month: 50 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4, cost_in_month: 300 }

      it { expect(ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects([first_project, second_project])).to eq(Time.zone.iso8601('2018-02-16T23:01:46').localtime(0).change(hour: 0).beginning_of_week => 2.0833333333333335) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects([project])).to eq({}) }
    end
  end

  describe '#sum_field_in_grouped_by_month_project_results' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46'), qty_hours_upstream: 20, qty_hours_downstream: 10 }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46'), qty_hours_upstream: 11, qty_hours_downstream: 13 }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46'), qty_hours_upstream: 23, qty_hours_downstream: 11 }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.sum_field_in_grouped_by_month_project_results([first_project, second_project], :qty_hours_upstream)).to eq([2018.0, 2.0] => 31) }
      it { expect(ProjectResultsRepository.instance.sum_field_in_grouped_by_month_project_results([first_project, second_project], :qty_hours_downstream)).to eq([2018.0, 2.0] => 23) }
    end
    context 'when there is no data' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.sum_field_in_grouped_by_month_project_results([project], :qty_hours_downstream)).to eq({}) }
    end
  end

  describe '#leadtime_80_in_week' do
    context 'when there is data in the week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46') }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46') }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46') }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.leadtime_80_in_week([first_project, second_project], Date.new(2018, 2, 15))).to eq first_result.leadtime_80_confidence }
    end
    context 'when there is data in the past week' do
      let!(:first_result) { Fabricate :project_result, project: first_project, result_date: Time.zone.iso8601('2018-02-16T23:01:46') }
      let!(:second_result) { Fabricate :project_result, project: second_project, result_date: Time.zone.iso8601('2018-02-15T23:01:46') }
      let!(:third_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.iso8601('2018-02-11T23:01:46') }
      let!(:out_result) { Fabricate :project_result, result_date: Time.zone.iso8601('2018-02-14T23:01:46'), flow_pressure: 4 }

      it { expect(ProjectResultsRepository.instance.leadtime_80_in_week([first_project, second_project], Date.new(2018, 3, 30))).to eq first_result.leadtime_80_confidence }
    end
    context 'having no project result' do
      let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 1.month.ago, end_date: 1.month.from_now }

      it { expect(ProjectResultsRepository.instance.leadtime_80_in_week([project], Date.new(2018, 2, 15))).to eq 0 }
    end
  end
end
