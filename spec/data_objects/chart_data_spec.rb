# frozen_string_literal: true

RSpec.describe ChartData, type: :data_object do
  context 'having projects' do
    let(:first_project) { Fabricate :project, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-03-22') }
    let(:second_project) { Fabricate :project, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21') }
    let(:third_project) { Fabricate :project, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-03-13') }

    let!(:first_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.parse('2018-02-21'), known_scope: 110, throughput_upstream: 23, throughput_downstream: 2, qty_hours_upstream: 10, qty_hours_downstream: 20, flow_pressure: 4) }
    let!(:second_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.parse('2018-03-18'), known_scope: 220, throughput_upstream: 10, throughput_downstream: 22, qty_hours_upstream: 13, qty_hours_downstream: 25, flow_pressure: 1) }
    let!(:third_project_result) { Fabricate(:project_result, project: second_project, result_date: Time.zone.parse('2018-03-13'), known_scope: 221, throughput_upstream: 15, throughput_downstream: 21, qty_hours_upstream: 9, qty_hours_downstream: 32, flow_pressure: 7) }
    let!(:fourth_project_result) { Fabricate(:project_result, project: third_project, result_date: Time.zone.parse('2018-03-12'), known_scope: 219, throughput_upstream: 12, throughput_downstream: 24, qty_hours_upstream: 21, qty_hours_downstream: 11, flow_pressure: 1) }
    let!(:fifth_project_result) { Fabricate(:project_result, project: third_project, result_date: Time.zone.parse('2018-03-13'), known_scope: 125, throughput_upstream: 10, throughput_downstream: 62, qty_hours_upstream: 87, qty_hours_downstream: 16, flow_pressure: 10) }

    let!(:opened_demands) { Fabricate.times(20, :demand, project: first_project, project_result: first_project_result, created_date: Time.zone.parse('2018-02-21')) }
    let!(:first_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, end_date: Time.zone.parse('2018-02-21'), leadtime: 2 * 86_400, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, end_date: Time.zone.parse('2018-02-21'), leadtime: 3 * 86_400, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: first_project, project_result: second_project_result, end_date: Time.zone.parse('2018-03-18'), leadtime: 1 * 86_400, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: first_project, project_result: second_project_result, end_date: Time.zone.parse('2018-03-18'), leadtime: 1 * 86_400, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: first_project, project_result: third_project_result, end_date: Time.zone.parse('2018-03-13'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

    describe '.initialize' do
      subject(:chart_data) { ChartData.new(Project.all) }

      it 'do the math and provides the correct information' do
        expect(chart_data.all_projects).to eq Project.all
        expect(chart_data.active_projects).to eq Project.active
        expect(chart_data.active_weeks).to eq [[8, 2018], [9, 2018], [10, 2018], [11, 2018], [12, 2018]]
        expect(chart_data.all_projects_weeks).to eq [[8, 2018], [9, 2018], [10, 2018], [11, 2018], [12, 2018]]
        expect(chart_data.active_months).to eq [[2, 2018], [3, 2018]]
        expect(chart_data.all_projects_months).to eq [[2, 2018], [3, 2018]]
      end
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:chart_data) { ChartData.new(Project.all) }

      it 'returns empty arrays' do
        expect(chart_data.all_projects).to eq []
        expect(chart_data.active_projects).to eq []
        expect(chart_data.active_weeks).to eq []
        expect(chart_data.all_projects_weeks).to eq []
        expect(chart_data.active_months).to eq []
        expect(chart_data.all_projects_months).to eq []
      end
    end
  end
end
