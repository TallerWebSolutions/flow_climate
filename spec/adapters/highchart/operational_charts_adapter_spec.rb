# frozen_string_literal: true

RSpec.describe Highchart::OperationalChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-04-22'), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, customer: customer, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21'), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800, initial_scope: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_opened_demand) { Fabricate :demand, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00') }
    let!(:second_opened_demand) { Fabricate :demand, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00') }

    let!(:first_demand) { Fabricate :demand, project: first_project, demand_title: 'first_demand', downstream: true, created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), leadtime: 2 * 86_400, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, demand_title: 'second_demand', downstream: true, created_date: Time.zone.iso8601('2018-01-20T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), leadtime: 3 * 86_400, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, demand_title: 'third_demand', downstream: false, created_date: Time.zone.iso8601('2018-02-18T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, demand_title: 'fourth_demand', downstream: false, created_date: Time.zone.iso8601('2018-02-03T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, demand_title: 'fifth_demand', downstream: true, created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, demand_title: 'sixth_demand', downstream: false, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, project: first_project, demand_title: 'first_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, project: first_project, demand_title: 'second_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, project: first_project, demand_title: 'third_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, project: first_project, demand_title: 'fourth_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

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
      before { travel_to Date.new(2018, 11, 19) }
      after { travel_back }

      context 'having projects' do
        context 'and filtering by all periods' do
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to eq Project.all
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [39, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5940433521078682, 0.601915855948114, 0.607374491015044, 0.6149224026528174, 0.8028903030746348, 0.71414327977308, 0.6620094325492614, 0.6417582534806037, 0.6736263840462509, 0.6221367615146416, 0.5872238957492414, 0.5779711107860109]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_demand.demand_id, fourth_demand.leadtime_in_days.to_f], [second_demand.demand_id, (second_demand.leadtime / 86_400).to_f], [first_demand.demand_id, (first_demand.leadtime / 86_400).to_f], [fifth_demand.demand_id, (fifth_demand.leadtime / 86_400).to_f], [third_demand.demand_id, (third_demand.leadtime / 86_400).to_f], [sixth_demand.demand_id, (sixth_demand.leadtime / 86_400).to_f], [first_bug.demand_id, (first_bug.leadtime / 86_400).to_f], [second_bug.demand_id, (second_bug.leadtime / 86_400).to_f], [third_bug.demand_id, (third_bug.leadtime / 86_400).to_f], [fourth_bug.demand_id, (fourth_bug.leadtime / 86_400).to_f]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 4.0
            expect(report_data.leadtime_percentiles_on_time[:xcategories]).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.leadtime_percentiles_on_time[:leadtime_80_confidence]).to eq [0.0, 259_200.0, 241_920.0, 241_920.0, 311_040.0, 276_480.0, 276_480.0, 276_480.0, 276_480.0, 276_480.0, 276_480.0, 345_600.0]
            expect(report_data.leadtime_bins).to eq ['1.5 Dias', '2.5 Dias', '3.5 Dias']
            expect(report_data.leadtime_histogram_data).to eq [2.0, 1.0, 7.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [9.30232558139535, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 0, 0, 96.0, 0, 0, 120.0, 0, 432.0, 552.0, 0, 0], touch_times: [0, 72.0, 0, 0, 0, 0, 240.0, 0, 0, 0, 0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 100.0, 0, 0.0, 0, 0, 66.66666666666666, 0, 0.0, 0.0, 0, 0])
          end
        end
        context 'and filtering by last month' do
          before { travel_to Time.zone.local(2018, 5, 30, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'month') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to eq [first_project, third_project]
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [6.0, 12.0, 18.0, 24.0, 30.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [3, 3, 3, 8, 8]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [30, 30, 30, 30, 30]
            expect(report_data.flow_pressure_data).to eq [0.75, 1.0714285714285714, 0.7936507936507936, 0.6845238095238095, 0.6904761904761905]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 5.0]], data: { upstream: [224.0], downstream: [284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_bug.demand_id, 4.0], [third_bug.demand_id, 4.0], [second_bug.demand_id, 4.0], [first_bug.demand_id, 4.0], [sixth_demand.demand_id, 4.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 4.0
            expect(report_data.leadtime_percentiles_on_time[:xcategories]).to eq [Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.leadtime_percentiles_on_time[:leadtime_80_confidence]).to eq [311_040.0, 311_040.0, 311_040.0, 311_040.0, 345_600.0]
            expect(report_data.leadtime_bins).to eq ['4.0 Dias']
            expect(report_data.leadtime_histogram_data).to eq [0.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [11.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 4, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [11.76470588235294, 11.76470588235294, 11.76470588235294, 11.76470588235294, 11.76470588235294])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 0, 552.0, 0, 0], touch_times: [0, 0, 0, 0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 0, 0.0, 0, 0])
          end
        end

        context 'and filtering by quarter' do
          before { travel_to Time.zone.local(2018, 6, 29, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'quarter') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [39, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5940433521078682, 0.601915855948114, 0.607374491015044, 0.6149224026528174, 0.8028903030746348, 0.71414327977308, 0.6620094325492614, 0.6417582534806037, 0.6736263840462509, 0.6221367615146416, 0.5872238957492414, 0.5779711107860109]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [39.6, 0.0, 284.8], upstream: [0.0, 0.0, 224.0] }, keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[second_demand.demand_id, 3.0], [first_demand.demand_id, 2.0], [fifth_demand.demand_id, 4.0], [fourth_demand.demand_id, 1.0], [third_demand.demand_id, 1.0], [first_bug.demand_id, 4.0], [sixth_demand.demand_id, 4.0], [second_bug.demand_id, 4.0], [third_bug.demand_id, 4.0], [fourth_bug.demand_id, 4.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.0
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 4.0
            expect(report_data.leadtime_percentiles_on_time[:xcategories]).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.leadtime_percentiles_on_time[:leadtime_80_confidence]).to eq [0.0, 259_200.0, 241_920.0, 241_920.0, 311_040.0, 276_480.0, 276_480.0, 276_480.0, 276_480.0, 276_480.0, 276_480.0, 345_600.0]
            expect(report_data.leadtime_bins).to eq ['1.5 Dias', '2.5 Dias', '3.5 Dias']
            expect(report_data.leadtime_histogram_data).to eq [2.0, 1.0, 7.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [9.30232558139535, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 0, 0, 96.0, 0, 0, 120.0, 0, 432.0, 552.0, 0, 0], touch_times: [0, 72.0, 0, 0, 0, 0, 240.0, 0, 0, 0, 0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 100.0, 0, 0.0, 0, 0, 66.66666666666666, 0, 0.0, 0.0, 0, 0])
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.none, 'all') }

        it 'do the math and provides the correct information' do
          expect(report_data.all_projects).to eq []
          expect(report_data.all_projects_weeks).to eq []
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
      it { expect(report_data.hours_per_demand_per_week).to eq [0.0, 39.6, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 101.76, 0] }
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }

      it 'returns empty arrays' do
        expect(report_data.all_projects).to eq []
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
