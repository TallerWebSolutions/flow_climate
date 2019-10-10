# frozen_string_literal: true

RSpec.describe ChartsHelper, type: :helper do
  before { travel_to Time.zone.local(2019, 10, 10, 12, 53, 0) }

  after { travel_back }

  describe '#gantt_chart_to_projects' do
    let!(:project) { Fabricate :project, name: 'foo' }
    let!(:other_project) { Fabricate :project, name: 'bar' }

    it { expect(helper.gantt_chart_to_projects('bla', Project.all)).to eq [{ data: [{ completed: 0.0, end: 1_575_946_800_000, name: 'foo', start: 1_565_406_000_000 }, { completed: 0.0, end: 1_575_946_800_000, name: 'bar', start: 1_565_406_000_000 }], name: 'bla' }] }
    it { expect(helper.gantt_chart_to_projects('bla', Project.none)).to eq [{ data: [], name: 'bla' }] }
  end
end
