# frozen_string_literal: true

RSpec.describe ReportData, type: :data_object do
  context 'having projects' do
    let(:first_project) { Fabricate :project, status: :executing, start_date: 2.weeks.ago, end_date: 1.week.from_now }
    let(:second_project) { Fabricate :project, status: :waiting, start_date: 1.week.from_now, end_date: 2.weeks.from_now }
    let(:third_project) { Fabricate :project, status: :maintenance, start_date: 2.weeks.from_now, end_date: 3.weeks.from_now }

    let!(:first_project_result) { Fabricate(:project_result, project: first_project, result_date: first_project.start_date, known_scope: 10, throughput: 23, qty_hours_upstream: 10, qty_hours_downstream: 20, flow_pressure: 4) }
    let!(:second_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.today, known_scope: 20, throughput: 10, qty_hours_upstream: 13, qty_hours_downstream: 25, flow_pressure: 1) }
    let!(:third_project_result) { Fabricate(:project_result, project: second_project, result_date: second_project.start_date, known_scope: 21, throughput: 15, qty_hours_upstream: 9, qty_hours_downstream: 32, flow_pressure: 7) }
    let!(:fourth_project_result) { Fabricate(:project_result, project: third_project, result_date: third_project.start_date, known_scope: 19, throughput: 12, qty_hours_upstream: 21, qty_hours_downstream: 11, flow_pressure: 1) }
    let!(:fifth_project_result) { Fabricate(:project_result, project: third_project, result_date: third_project.end_date, known_scope: 25, throughput: 10, qty_hours_upstream: 87, qty_hours_downstream: 16, flow_pressure: 10) }

    describe '.initialize' do
      subject(:report_data) { ReportData.new(Project.all) }

      it 'do the math and provides the correct information' do
        expect(report_data.projects).to eq Project.all
        expect(report_data.weeks).to eq([
                                          [2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear],
                                          [1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear],
                                          [Time.zone.today.cweek, Time.zone.today.to_date.cwyear],
                                          [1.week.from_now.to_date.cweek, 1.week.from_now.to_date.cwyear],
                                          [2.weeks.from_now.to_date.cweek, 2.weeks.from_now.to_date.cwyear],
                                          [3.weeks.from_now.to_date.cweek, 3.weeks.from_now.to_date.cwyear]
                                        ])
        expect(report_data.ideal).to eq [11.833333333333334, 23.666666666666668, 35.5, 47.333333333333336, 59.16666666666667, 71.0]
        expect(report_data.current).to eq [23, 23, 33]
        expect(report_data.scope).to eq [70, 70, 80, 71, 60, 66]
        expect(report_data.flow_pressure_data).to eq [4.0, 0.0, 1.0, 7.0, 0.2698412698412699, 1.0, 1.5238095238095237, 10.0, 0.8888888888888888]
        expect(report_data.throughput_per_week).to eq [23, 0, 10]
      end
    end
    describe '#projects_names' do
      subject(:report_data) { ReportData.new(Project.all) }
      it { expect(report_data.projects_names).to eq [first_project.full_name, second_project.full_name, third_project.full_name] }
    end

    describe '#hours_per_demand_per_week' do
      subject(:report_data) { ReportData.new(Project.all) }
      it { expect(report_data.hours_per_demand_per_week).to eq [1.3043478260869565, 0, 3.8] }
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:report_data) { ReportData.new(Project.all) }

      it 'returns empty arrays' do
        expect(report_data.projects).to eq []
        expect(report_data.weeks).to eq []
        expect(report_data.ideal).to eq []
        expect(report_data.current).to eq []
        expect(report_data.scope).to eq []
        expect(report_data.flow_pressure_data).to eq []
        expect(report_data.throughput_per_week).to eq []
      end
    end

    describe '#projects_names' do
      subject(:report_data) { ReportData.new(Project.all) }
      it { expect(report_data.projects_names).to eq [] }
    end

    describe '#hours_per_demand_per_week' do
      subject(:report_data) { ReportData.new(Project.all) }
      it { expect(report_data.hours_per_demand_per_week).to eq [] }
    end
  end
end
