# frozen_string_literal: true

RSpec.describe Highchart::OperationalChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-04-22'), qty_hours: 1000 }
    let(:second_project) { Fabricate :project, customer: customer, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-04-21'), qty_hours: 400 }
    let(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.parse('2018-02-21'), known_scope: 110, throughput_upstream: 23, throughput_downstream: 2, qty_hours_upstream: 10, qty_hours_downstream: 20, flow_pressure: 4, qty_bugs_opened: 10, qty_bugs_closed: 2, leadtime_80_confidence: 1280) }
    let!(:second_project_result) { Fabricate(:project_result, project: first_project, result_date: Time.zone.parse('2018-03-18'), known_scope: 220, throughput_upstream: 10, throughput_downstream: 22, qty_hours_upstream: 13, qty_hours_downstream: 25, flow_pressure: 1, qty_bugs_opened: 1, qty_bugs_closed: 5, leadtime_80_confidence: 4385) }
    let!(:third_project_result) { Fabricate(:project_result, project: second_project, result_date: Time.zone.parse('2018-03-13'), known_scope: 221, throughput_upstream: 15, throughput_downstream: 21, qty_hours_upstream: 9, qty_hours_downstream: 32, flow_pressure: 7, qty_bugs_opened: 2, qty_bugs_closed: 7, leadtime_80_confidence: 5670) }
    let!(:fourth_project_result) { Fabricate(:project_result, project: third_project, result_date: Time.zone.parse('2018-03-12'), known_scope: 219, throughput_upstream: 12, throughput_downstream: 24, qty_hours_upstream: 21, qty_hours_downstream: 11, flow_pressure: 1, qty_bugs_opened: 3, qty_bugs_closed: 6, leadtime_80_confidence: 3360) }
    let!(:fifth_project_result) { Fabricate(:project_result, project: third_project, result_date: Time.zone.parse('2018-03-13'), known_scope: 125, throughput_upstream: 10, throughput_downstream: 62, qty_hours_upstream: 87, qty_hours_downstream: 16, flow_pressure: 10, qty_bugs_opened: 8, qty_bugs_closed: 9, leadtime_80_confidence: 55_320) }

    let!(:first_opened_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00') }
    let!(:second_opened_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00') }

    let!(:first_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), leadtime: 2 * 86_400, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, project_result: first_project_result, end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), leadtime: 3 * 86_400, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, project_result: second_project_result, end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, project_result: second_project_result, end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, project_result: third_project_result, end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, project_result: third_project_result, end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

    let!(:queue_ongoing_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-02-10T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-14T17:09:58-03:00') }
    let!(:touch_ongoing_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-03-10T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-03-14T17:09:58-03:00') }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-02-27T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-03-02T17:09:58-03:00') }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.iso8601('2018-02-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-10T17:09:58-03:00') }
    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.iso8601('2018-04-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-20T17:09:58-03:00') }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: fourth_demand, last_time_in: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-02T17:09:58-03:00') }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: fifth_demand, last_time_in: Time.zone.iso8601('2018-03-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-02T17:09:58-03:00') }
    let!(:sixth_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.iso8601('2018-04-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-25T17:09:58-03:00') }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.iso8601('2018-03-25T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-04T17:09:58-03:00') }
    let!(:eigth_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.iso8601('2018-03-30T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-04T17:09:58-03:00') }

    describe '.initialize' do
      context 'having projects' do
        context 'and filtering by all periods' do
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to eq Project.all
            expect(report_data.active_projects).to eq Project.active
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.active_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [47.166666666666664, 94.33333333333333, 141.5, 188.66666666666666, 235.83333333333331, 283.0, 330.16666666666663, 377.3333333333333, 424.5, 471.66666666666663, 518.8333333333333, 566.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [25, 25, 25, 201, 201, 201, 201, 201, 201, 201, 201, 201]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [170, 170, 170, 566, 566, 566, 566, 566, 566, 566, 566, 566]
            expect(report_data.flow_pressure_data).to eq [4.0, 0.0, 0.0, 4.75, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [23, 0, 0, 47, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [2, 0, 0, 129, 0, 0, 0, 0, 0, 0, 0, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 0.0], downstream: [39.6, 0.0, 184.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_demand.demand_id, (fourth_demand.leadtime / 86_400).to_f], [second_demand.demand_id, (second_demand.leadtime / 86_400).to_f], [first_demand.demand_id, (first_demand.leadtime / 86_400).to_f], [fifth_demand.demand_id, (fifth_demand.leadtime / 86_400).to_f], [third_demand.demand_id, (third_demand.leadtime / 86_400).to_f], [sixth_demand.demand_id, (sixth_demand.leadtime / 86_400).to_f]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 3.0
            expect(report_data.leadtime_percentiles_on_time[:xcategories]).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.leadtime_percentiles_on_time[:leadtime_80_confidence]).to eq [0.35555555555555557, 0.35555555555555557, 0.35555555555555557, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554]
            expect(report_data.leadtime_bins).to eq ['1.75 Dias', '3.25 Dias']
            expect(report_data.leadtime_histogram_data).to eq [3.0, 3.0]
            expect(report_data.throughput_bins).to eq ['0.33 demanda(s)', '1.0 demanda(s)', '1.67 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [7.0, 4.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [10, 10, 10, 24, 24, 24, 24, 24, 24, 24, 24, 24], bugs_closed_count_array: [2, 2, 2, 29, 29, 29, 29, 29, 29, 29, 29, 29])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [5.555555555555555, 5.555555555555555, 5.555555555555555, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 0, 0, 345_600.0, 0, 0, 432_000.0, 0, 1_555_200.0, 1_987_200.0, 0, 0], touch_times: [0, 259_200.0, 0, 0, 0, 0, 864_000.0, 0, 0, 0, 0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 100.0, 0, 0.0, 0, 0, 66.66666666666666, 0, 0.0, 0.0, 0, 0])
          end
        end
        context 'and filtering by last month' do
          before { travel_to Time.zone.local(2018, 5, 30, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'month') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to eq [third_project]
            expect(report_data.active_projects).to eq [third_project]
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.active_weeks).to eq [Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [62.5, 125.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [108, 108]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [125, 125]
            expect(report_data.flow_pressure_data).to eq [0.0, 0.0]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [0, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [], data: { upstream: [], downstream: [] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to eq []
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 0
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 0
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 0
            expect(report_data.leadtime_percentiles_on_time[:xcategories]).to eq [Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.leadtime_percentiles_on_time[:leadtime_80_confidence]).to eq [15.366666666666667, 15.366666666666667]
            expect(report_data.leadtime_bins).to eq []
            expect(report_data.leadtime_histogram_data).to eq []
            expect(report_data.throughput_bins).to eq ['0.0 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [0.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-04-30 2018-05-07], bugs_opened_count_array: [11, 11], bugs_closed_count_array: [15, 15])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-04-30 2018-05-07], bugs_opened_share_array: [8.088235294117647, 8.088235294117647])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-04-30 2018-05-07], queue_times: [0, 0], touch_times: [0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-04-30 2018-05-07], flow_efficiency_array: [0, 0])
          end
        end

        context 'and filtering by quarter' do
          before { travel_to Time.zone.local(2018, 6, 29, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'quarter') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.active_projects).to match_array Project.active
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.active_weeks).to eq [Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [80.85714285714286, 161.71428571428572, 242.57142857142858, 323.42857142857144, 404.28571428571433, 485.14285714285717, 566.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [201, 201, 201, 201, 201, 201, 201]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [566, 566, 566, 566, 566, 566, 566]
            expect(report_data.flow_pressure_data).to eq [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [0, 0, 0, 0, 0, 0, 0] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [184.8], upstream: [0.0] }, keys: [[2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to eq [[sixth_demand.demand_id, 4.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 4.0
            expect(report_data.leadtime_percentiles_on_time[:xcategories]).to eq [Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.leadtime_percentiles_on_time[:leadtime_80_confidence]).to eq [1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554, 1.2180555555555554]
            expect(report_data.leadtime_bins).to eq ['4.0 Dias']
            expect(report_data.leadtime_histogram_data).to eq [1.0]
            expect(report_data.throughput_bins).to eq ['0.17 demanda(s)', '0.5 demanda(s)', '0.83 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [11.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [24, 24, 24, 24, 24, 24, 24], bugs_closed_count_array: [29, 29, 29, 29, 29, 29, 29])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491, 4.067796610169491])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 432_000.0, 0, 1_555_200.0, 1_987_200.0, 0, 0], touch_times: [0, 864_000.0, 0, 0, 0, 0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 66.66666666666666, 0, 0.0, 0.0, 0, 0])
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.none, 'all') }

        it 'do the math and provides the correct information' do
          expect(report_data.all_projects).to eq []
          expect(report_data.active_projects).to eq []
          expect(report_data.all_projects_weeks).to eq []
          expect(report_data.active_weeks).to eq []
          expect(report_data.demands_burnup_data.ideal_per_period).to eq []
          expect(report_data.demands_burnup_data.current_per_period).to eq []
          expect(report_data.demands_burnup_data.scope_per_period).to eq []
          expect(report_data.flow_pressure_data).to eq []
          expect(report_data.throughput_per_week).to eq([{ name: 'Upstream', data: [] }, { name: 'Downstream', data: [] }])
          expect(report_data.effort_hours_per_month).to eq(keys: [], data: { upstream: [], downstream: [] })
          expect(report_data.lead_time_control_chart[:dispersion_source]).to eq []
          expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 0
          expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 0
          expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 0
          expect(report_data.leadtime_bins).to eq []
          expect(report_data.leadtime_histogram_data).to eq []
          expect(report_data.throughput_bins).to eq []
          expect(report_data.throughput_histogram_data).to eq []
        end
      end
    end
    describe '#hours_per_demand_per_week' do
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }
      it { expect(report_data.hours_per_demand_per_week).to eq [15.0, 0, 0, 1.6589147286821706, 0, 0, 0, 0, 0, 0, 0, 0] }
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }

      it 'returns empty arrays' do
        expect(report_data.all_projects).to eq []
        expect(report_data.active_projects).to eq []
        expect(report_data.active_weeks).to eq []
        expect(report_data.all_projects_weeks).to eq []
        expect(report_data.demands_burnup_data.ideal_per_period).to eq []
        expect(report_data.demands_burnup_data.current_per_period).to eq []
        expect(report_data.demands_burnup_data.scope_per_period).to eq []
        expect(report_data.flow_pressure_data).to eq []
        expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [] }])
      end
    end

    describe '#hours_per_demand_per_week' do
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }
      it { expect(report_data.hours_per_demand_per_week).to eq [] }
    end
  end
end
