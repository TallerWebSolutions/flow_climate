# frozen_string_literal: true

RSpec.describe ReportData, type: :data_object do
  context 'having projects' do
    let(:project) { Fabricate :project, start_date: 2.weeks.ago, end_date: 1.week.from_now }
    let!(:first_project_result) { Fabricate(:project_result, project: project, result_date: project.start_date, known_scope: 10, throughput: 23, qty_hours_upstream: 10, qty_hours_downstream: 20, flow_pressure: 4) }
    let!(:second_project_result) { Fabricate(:project_result, project: project, result_date: 1.week.ago, known_scope: 20, throughput: 10, qty_hours_upstream: 13, qty_hours_downstream: 25, flow_pressure: 1) }
    let!(:third_project_result) { Fabricate(:project_result, project: project, result_date: 1.week.ago, known_scope: 21, throughput: 15, qty_hours_upstream: 9, qty_hours_downstream: 32, flow_pressure: 7) }
    let!(:fourth_project_result) { Fabricate(:project_result, project: project, result_date: Time.zone.today, known_scope: 19, throughput: 12, qty_hours_upstream: 21, qty_hours_downstream: 11, flow_pressure: 1) }
    let!(:fifth_project_result) { Fabricate(:project_result, project: project, result_date: 1.week.from_now, known_scope: 25, throughput: 28, qty_hours_upstream: 87, qty_hours_downstream: 16, flow_pressure: 10) }

    describe '.initialize' do
      subject(:report_data) { ReportData.new(Project.all) }

      it 'do the math and provides the correct information' do
        expect(report_data.projects).to eq Project.all
        expect(report_data.weeks).to eq [[2.weeks.ago.to_date.cweek, 2.weeks.ago.to_date.cwyear], [1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear], [Time.zone.today.cweek, Time.zone.today.to_date.cwyear], [1.week.from_now.to_date.cweek, 1.week.from_now.to_date.cwyear]]
        expect(report_data.ideal).to eq [4.75, 9.5, 14.25, 19.0]
        expect(report_data.current).to eq [23, 48]
        expect(report_data.scope).to eq [10, 20, 19, 25]
        expect(report_data.flow_pressure_data).to eq [4.0, 1.0]
        expect(report_data.throughput_per_week).to eq [23, 25]
      end
    end
    describe '#projects_names' do
      subject(:report_data) { ReportData.new(Project.all) }
      it { expect(report_data.projects_names).to eq [project.full_name] }
    end

    describe '#hours_per_demand_per_week' do
      subject(:report_data) { ReportData.new(Project.all) }
      it { expect(report_data.hours_per_demand_per_week).to eq [1.3043478260869565, 3.16] }
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
