# frozen_string_literal: true

describe ReportData, type: :data_object do
  describe '.initialize' do
    let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today }
    let!(:project_results) { Fabricate.times(10, :project_result, project: project, result_date: project.start_date) }

    subject(:report_data) { ReportData.new(Project.all) }

    it 'do the math and provides the correct information' do
      expect(report_data.projects).to eq Project.all
      expect(report_data.weeks).to eq [[project.start_date.cweek, project.start_date.cwyear]]
      expect(report_data.ideal).to eq [project.current_backlog.to_f / 1.0]
      expect(report_data.current).to eq [project_results.sum(&:throughput)]
      expect(report_data.scope).to eq [project.current_backlog]
    end
  end

  describe '#projects_names' do
    let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today }
    let!(:project_results) { Fabricate.times(10, :project_result, project: project, result_date: project.start_date) }

    subject(:report_data) { ReportData.new(Project.all) }

    it { expect(report_data.projects_names).to eq [project.full_name] }
  end

  describe '#hours_per_demand_chart_data_for_week' do
    let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today }
    let!(:project_results) { Fabricate.times(10, :project_result, project: project, result_date: project.start_date) }

    subject(:report_data) { ReportData.new(Project.all) }

    it { expect(report_data.hours_per_demand_chart_data_for_week(ProjectResult.all)).to eq [project_results.sum(&:hours_per_demand)] }
  end
end
