# frozen_string_literal: true

RSpec.describe Highchart::StatusReportChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-04-22'), qty_hours: 1000 }
    let(:second_project) { Fabricate :project, customer: customer, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-04-21'), qty_hours: 400 }
    let(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800 }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, queue: true, end_point: true }

    let(:sixth_stage) { Fabricate :stage, company: company, projects: [first_project, second_project, third_project], stage_stream: :upstream, end_point: false }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: first_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: second_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: third_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:fourth_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: fourth_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:fifth_stage_project_config) { Fabricate :stage_project_config, project: third_project, stage: fifth_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.parse('2018-02-21'), known_scope: 110, throughput_upstream: 23, throughput_downstream: 2, qty_hours_upstream: 10, qty_hours_downstream: 20, flow_pressure: 4, qty_bugs_opened: 10, qty_bugs_closed: 2) }
    let!(:second_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.parse('2018-03-18'), known_scope: 220, throughput_upstream: 10, throughput_downstream: 22, qty_hours_upstream: 13, qty_hours_downstream: 25, flow_pressure: 1, qty_bugs_opened: 1, qty_bugs_closed: 5) }
    let!(:third_project_result) { Fabricate(:project_result, project: second_project, result_date: Time.zone.parse('2018-03-13'), known_scope: 221, throughput_upstream: 15, throughput_downstream: 21, qty_hours_upstream: 9, qty_hours_downstream: 32, flow_pressure: 7, qty_bugs_opened: 2, qty_bugs_closed: 7) }
    let!(:fourth_project_result) { Fabricate(:project_result, project: third_project, result_date: Time.zone.parse('2018-03-12'), known_scope: 219, throughput_upstream: 12, throughput_downstream: 24, qty_hours_upstream: 21, qty_hours_downstream: 11, flow_pressure: 1, qty_bugs_opened: 3, qty_bugs_closed: 6) }
    let!(:fifth_project_result) { Fabricate(:project_result, project: third_project, result_date: Time.zone.parse('2018-03-13'), known_scope: 125, throughput_upstream: 10, throughput_downstream: 62, qty_hours_upstream: 87, qty_hours_downstream: 16, flow_pressure: 10, qty_bugs_opened: 8, qty_bugs_closed: 9) }

    let!(:opened_demands) { Fabricate.times(20, :demand, project: first_project, project_result: first_project_result, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00')) }
    let!(:first_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, created_date: Time.zone.iso8601('2018-02-10T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), leadtime: 2 * 86_400, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), leadtime: 3 * 86_400, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, project_result: second_project_result, created_date: Time.zone.iso8601('2018-02-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, project_result: second_project_result, created_date: Time.zone.iso8601('2018-02-05T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, project_result: third_project_result, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-02-27T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-03-02T17:09:58-03:00') }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.iso8601('2018-02-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-10T17:09:58-03:00') }
    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.iso8601('2018-04-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-20T17:09:58-03:00') }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: fourth_demand, last_time_in: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-02T17:09:58-03:00') }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: fifth_demand, last_time_in: Time.zone.iso8601('2018-03-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-02T17:09:58-03:00') }

    let!(:sixth_transition) { Fabricate :demand_transition, stage: sixth_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-02-27T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-03-02T17:09:58-03:00') }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: sixth_stage, demand: second_demand, last_time_in: Time.zone.iso8601('2018-02-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-10T17:09:58-03:00') }
    let!(:eigth_transition) { Fabricate :demand_transition, stage: sixth_stage, demand: third_demand, last_time_in: Time.zone.iso8601('2018-04-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-20T17:09:58-03:00') }
    let!(:nineth_transition) { Fabricate :demand_transition, stage: sixth_stage, demand: fourth_demand, last_time_in: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-02T17:09:58-03:00') }
    let!(:tenth_transition) { Fabricate :demand_transition, stage: sixth_stage, demand: fifth_demand, last_time_in: Time.zone.iso8601('2018-03-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-02T17:09:58-03:00') }

    describe '.initialize' do
      context 'having projects' do
        subject(:report_data) { Highchart::StatusReportChartsAdapter.new(Project.all, 'all') }

        it 'do the math and provides the correct information' do
          expect(report_data.all_projects).to match_array Project.all
          expect(report_data.active_projects).to match_array Project.active
          expect(report_data.all_projects_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
          expect(report_data.active_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
          expect(report_data.hours_burnup_per_week_data.ideal_per_period).to eq [183.33333333333334, 366.6666666666667, 550.0, 733.3333333333334, 916.6666666666667, 1100.0, 1283.3333333333335, 1466.6666666666667, 1650.0, 1833.3333333333335, 2016.6666666666667, 2200.0]
          expect(report_data.hours_burnup_per_week_data.current_per_period).to eq [30, 30, 30, 244, 244, 244, 244, 244, 244, 244, 244, 244]
          expect(report_data.hours_burnup_per_week_data.scope_per_period).to eq [2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0]
          expect(report_data.hours_burnup_per_month_data.ideal_per_period).to eq [733.3333333333334, 1466.6666666666667, 2200.0]
          expect(report_data.hours_burnup_per_month_data.current_per_period).to eq [30, 244, 244]
          expect(report_data.hours_burnup_per_month_data.scope_per_period).to eq [2200.0, 2200.0, 2200.0]
          expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [23, 0, 0, 47, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [2, 0, 0, 129, 0, 0, 0, 0, 0, 0, 0, 0] }])
          expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [22] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [5] }, { name: I18n.t('projects.show.scope_gap'), data: [110] }])
          expect(report_data.dates_to_montecarlo_duration).not_to be_empty
          expect(report_data.confidence_95_duration).to be_within(6).of(306)
          expect(report_data.confidence_80_duration).to be_within(6).of(286)
          expect(report_data.confidence_60_duration).to be_within(6).of(269)
          expect(report_data.hours_per_stage).to eq(xcategories: [sixth_stage.name], hours_per_stage: [1104.0])
        end
      end
      context 'having no projects' do
        subject(:report_data) { Highchart::StatusReportChartsAdapter.new(Project.none, 'all') }

        it 'return empty sets' do
          expect(report_data.all_projects).to eq []
          expect(report_data.active_projects).to eq []
          expect(report_data.all_projects_weeks).to eq []
          expect(report_data.active_weeks).to eq []
          expect(report_data.hours_burnup_per_week_data.ideal_per_period).to eq []
          expect(report_data.hours_burnup_per_week_data.current_per_period).to eq []
          expect(report_data.hours_burnup_per_week_data.scope_per_period).to eq []
          expect(report_data.hours_burnup_per_month_data.ideal_per_period).to eq []
          expect(report_data.hours_burnup_per_month_data.current_per_period).to eq []
          expect(report_data.hours_burnup_per_month_data.scope_per_period).to eq []
          expect(report_data.throughput_per_week).to eq([{ name: 'Upstream', data: [] }, { name: 'Downstream', data: [] }])
          expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [0] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [0] }, { name: I18n.t('projects.show.scope_gap'), data: [0] }])
          expect(report_data.dates_to_montecarlo_duration).to eq []
          expect(report_data.confidence_95_duration).to eq 0
          expect(report_data.confidence_80_duration).to eq 0
          expect(report_data.confidence_60_duration).to eq 0
        end
      end
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:report_data) { Highchart::StatusReportChartsAdapter.new(Project.all, 'all') }

      it 'returns empty arrays' do
        expect(report_data.all_projects).to eq []
        expect(report_data.active_projects).to eq []
        expect(report_data.active_weeks).to eq []
        expect(report_data.all_projects_weeks).to eq []
        expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [] }])
        expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [0] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [0] }, { name: I18n.t('projects.show.scope_gap'), data: [0] }])
      end
    end
  end
end
