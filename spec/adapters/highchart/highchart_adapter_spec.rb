# frozen_string_literal: true

RSpec.describe Highchart::HighchartAdapter, type: :data_object do
  context 'having projects' do
    let!(:first_project) { Fabricate :project, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-03-22') }
    let!(:second_project) { Fabricate :project, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21') }
    let!(:third_project) { Fabricate :project, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-03-13') }

    let!(:opened_demands) { Fabricate.times(20, :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: nil) }
    let!(:first_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-02-21'), leadtime: 2 * 86_400, effort_upstream: 10, effort_downstream: 5, downstream: false }
    let!(:second_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-02-21'), leadtime: 3 * 86_400, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-03-18'), leadtime: 1 * 86_400, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-03-18'), leadtime: 1 * 86_400, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.parse('2018-02-21'), end_date: Time.zone.parse('2018-03-13'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

    describe '.initialize' do
      context 'querying all the time' do
        before { travel_to Time.zone.local(2018, 5, 30, 10, 0, 0) }
        after { travel_back }

        subject(:chart_data) { Highchart::HighchartAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

        it 'do the math and provides the correct information' do
          expect(chart_data.x_axis).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19)]
          expect(chart_data.all_projects).to match_array Project.all
          expect(chart_data.all_projects_demands_ids).to match_array Demand.all.map(&:id)
          expect(chart_data.upstream_operational_weekly_data).to eq(Date.new(2018, 2, 19) => { throughput: 1, total_effort_downstream: 5.0, total_effort_upstream: 10.0, total_queue_time: 0.0, total_touch_time: 0.0 })
          expect(chart_data.downstream_operational_weekly_data).to eq(Date.new(2018, 2, 19) => { total_effort_upstream: 12.0, total_effort_downstream: 20.0, throughput: 1, total_queue_time: 0.0, total_touch_time: 0.0 }, Date.new(2018, 3, 12) => { total_effort_upstream: 163.0, total_effort_downstream: 99.0, throughput: 3, total_queue_time: 0.0, total_touch_time: 0.0 })
        end
      end
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:chart_data) { Highchart::HighchartAdapter.new(Project.all, 1.day.ago, 1.day.from_now, 'week') }

      it 'returns empty data' do
        expect(chart_data.x_axis).to eq []
        expect(chart_data.all_projects).to eq []
        expect(chart_data.all_projects_demands_ids).to eq []
        expect(chart_data.upstream_operational_weekly_data).to eq({})
        expect(chart_data.downstream_operational_weekly_data).to eq({})
      end
    end
  end
end
