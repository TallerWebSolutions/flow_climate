# frozen_string_literal: true

RSpec.describe ChartsHelper, type: :helper do
  before { travel_to Time.zone.local(2019, 10, 10, 12, 53, 0) }

  after { travel_back }

  describe '#gantt_chart_to_projects' do
    let!(:project) { Fabricate :project, name: 'foo' }
    let!(:other_project) { Fabricate :project, name: 'bar' }

    it { expect(helper.gantt_chart_to_projects('bla', Project.all)).to eq [{ data: [{ completed: 0.0, start: project.start_date.to_time.to_i * 1000, end: project.end_date.to_time.to_i * 1000, name: 'foo' }, { completed: 0.0, start: other_project.start_date.to_time.to_i * 1000, end: other_project.end_date.to_time.to_i * 1000, name: 'bar' }], name: 'bla' }] }
    it { expect(helper.gantt_chart_to_projects('bla', Project.none)).to eq [{ data: [], name: 'bla' }] }
  end
end
