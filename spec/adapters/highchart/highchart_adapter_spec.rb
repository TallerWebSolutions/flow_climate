# frozen_string_literal: true

RSpec.describe Highchart::HighchartAdapter, type: :data_object do
  context 'having projects' do
    let!(:first_project) { Fabricate :project, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-03-22') }
    let!(:second_project) { Fabricate :project, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21') }
    let!(:third_project) { Fabricate :project, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-03-13') }

    let!(:opened_demands) { Fabricate.times(20, :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: nil) }
    let!(:first_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-02-21'), leadtime: 1.day * 2, effort_upstream: 10, effort_downstream: 5, commitment_date: nil }
    let!(:second_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-02-21'), leadtime: 1.day * 3, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-03-18'), leadtime: 1.day * 1, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-03-18'), leadtime: 1.day * 1, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-03-13'), leadtime: 1.day * 4, effort_upstream: 56, effort_downstream: 25 }

    describe '.initialize' do
      context 'querying all the time' do
        subject(:chart_data) { described_class.new(Demand.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

        before { travel_to Time.zone.local(2018, 5, 30, 10, 0, 0) }

        it 'do the math and provides the correct information' do
          expect(chart_data.x_axis).to eq [Date.new(2018, 2, 25), Date.new(2018, 3, 4), Date.new(2018, 3, 11), Date.new(2018, 3, 18), Date.new(2018, 3, 25)]
          expect(chart_data.x_axis_index).to eq [1, 2, 3, 4, 5]
          expect(chart_data.all_projects).to match_array [first_project, second_project]
        end
      end
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:chart_data) { described_class.new(Project.all, 1.day.ago, 1.day.from_now, 'week') }

      it 'returns empty data' do
        expect(chart_data.x_axis).to eq []
        expect(chart_data.x_axis_index).to eq []
        expect(chart_data.all_projects).to eq []
      end
    end
  end
end
