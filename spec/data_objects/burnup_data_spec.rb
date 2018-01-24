# frozen_string_literal: true

describe BurnupData, type: :data_object do
  describe '.initialize' do
    let(:project) { Fabricate :project, start_date: Time.zone.today, end_date: Time.zone.today }
    let!(:project_results) { Fabricate.times(10, :project_result, project: project, result_date: project.start_date) }

    subject(:burnup_data) { BurnupData.new(project) }

    it 'do the math and provides the correct information' do
      expect(burnup_data.project).to eq project
      expect(burnup_data.weeks).to eq [[project.start_date.cweek, project.start_date.cwyear]]
      expect(burnup_data.ideal).to eq [project.current_backlog.to_f / project.project_weeks.count.to_f]
      expect(burnup_data.current).to eq [project_results.sum(&:throughput)]
      expect(burnup_data.scope).to eq [project.current_backlog]
    end
  end
end
