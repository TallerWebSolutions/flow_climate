# frozen_string_literal: true

RSpec.describe Highchart::OperationalChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, name: 'first_project', start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-04-22'), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, customer: customer, status: :waiting, name: 'second_project', start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21'), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, customer: customer, status: :maintenance, name: 'third_project', start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800, initial_scope: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_opened_demand) { Fabricate :demand, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: nil }
    let!(:second_opened_demand) { Fabricate :demand, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: nil }

    let!(:first_demand) { Fabricate :demand, project: first_project, demand_id: 'first_demand', downstream: true, created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-19T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, demand_id: 'second_demand', downstream: true, created_date: Time.zone.iso8601('2018-01-20T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, demand_id: 'third_demand', downstream: false, created_date: Time.zone.iso8601('2018-02-18T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-17T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, demand_id: 'fourth_demand', downstream: false, created_date: Time.zone.iso8601('2018-02-03T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-10T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, demand_id: 'fifth_demand', downstream: true, created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-09T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, demand_id: 'sixth_demand', downstream: false, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, project: first_project, demand_id: 'first_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-30T10:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, project: first_project, demand_id: 'second_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-25T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, project: first_project, demand_id: 'third_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, project: first_project, demand_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }

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
        context 'and using the week period interval' do
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [0, 1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.6079086605402394, 0.6119437482595377, 0.6194386483003373, 0.7685507211180406, 0.6672543699978808, 0.611894497901687, 0.5916767653972133, 0.6206266524811823, 1.198132782003475, 1.10054172602535, 1.0383712660836515, 1.229618105021125]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [0, 1, 2, 2, 2, 3, 3, 3, 3, 3, 3, 8] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_demand.demand_id, fourth_demand.leadtime_in_days.to_f], [second_demand.demand_id, (second_demand.leadtime / 86_400).to_f], [first_demand.demand_id, (first_demand.leadtime / 86_400).to_f], [fifth_demand.demand_id, (fifth_demand.leadtime / 86_400).to_f], [third_demand.demand_id, (third_demand.leadtime / 86_400).to_f], [sixth_demand.demand_id, (sixth_demand.leadtime / 86_400).to_f], [first_bug.demand_id, (first_bug.leadtime / 86_400).to_f], [second_bug.demand_id, (second_bug.leadtime / 86_400).to_f], [third_bug.demand_id, (third_bug.leadtime / 86_400).to_f], [fourth_bug.demand_id, (fourth_bug.leadtime / 86_400).to_f]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.42 demanda(s)', '1.25 demanda(s)', '2.08 demanda(s)', '2.92 demanda(s)', '3.75 demanda(s)', '4.58 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [35.0, 3.0, 1.0, 0.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 672.0, 0], touch_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 240.0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 50.0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421, 0])
          end
        end
        context 'and using the month period interval' do
          before { travel_to Time.zone.local(2018, 5, 15, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'month') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 1), Date.new(2018, 3, 1), Date.new(2018, 4, 1), Date.new(2018, 5, 1)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [10.5, 21.0, 31.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [0, 2, 5, 5]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [38, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5570063150708312, 0.5864925755248336, 0.5026934294901286, 0.48118673878426316]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 2, 2] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [0, 2, 3, 3] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fifth_demand.demand_id, 4.0], [first_bug.demand_id, 0.5416666666666666], [first_demand.demand_id, 7.797361111111111], [fourth_bug.demand_id, 1.0], [second_demand.demand_id, 1.0], [sixth_demand.demand_id, 1.0], [fourth_demand.demand_id, 8.0], [third_demand.demand_id, 2.0], [second_bug.demand_id, 5.0], [third_bug.demand_id, 1.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.63 demanda(s)', '1.88 demanda(s)', '3.13 demanda(s)', '4.38 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [11.0, 1.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-01 2018-03-01 2018-04-01 2018-05-01], bugs_opened_count_array: [4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-01 2018-03-01 2018-04-01 2018-05-01], bugs_opened_share_array: [9.523809523809524, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-01 2018-03-01 2018-04-01 2018-05-01], queue_times: [0, 96.0, 0, 672.0], touch_times: [0, 96.0, 0, 240.0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-01 2018-03-01 2018-04-01 2018-05-01], flow_efficiency_array: [0, 50.0, 0, 26.31578947368421])
          end
        end

        context 'and using the day period interval' do
          before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Date.new(2018, 2, 1), Date.new(2018, 2, 10), 'day') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 2, 1), Date.new(2018, 2, 10))
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.9, 7.8, 11.7, 15.6, 19.5, 23.4, 27.3, 31.2, 35.1, 39.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [38, 38, 38, 38, 39, 39, 39, 39, 39, 39]
            expect(report_data.flow_pressure_data).to eq [0.5570063150708312, 0.5570063150708312, 0.5570063150708312, 0.5570063150708312, 0.5570063150708312, 0.5570063150708312, 0.5570063150708313, 0.5570063150708312, 0.5570063150708312, 0.5570063150708312]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [39.6, 0.0, 284.8], upstream: [0.0, 0.0, 224.0] }, keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[second_demand.demand_id, 1.0], [first_demand.demand_id, 7.797361111111111], [fifth_demand.demand_id, 4.0], [fourth_demand.demand_id, 8.0], [third_demand.demand_id, 2.0], [first_bug.demand_id, 0.5416666666666666], [sixth_demand.demand_id, 1.0], [second_bug.demand_id, 5.0], [third_bug.demand_id, 1.0], [fourth_bug.demand_id, 1.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.63 demanda(s)', '1.88 demanda(s)', '3.13 demanda(s)', '4.38 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [15.0, 1.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-01 2018-02-02 2018-02-03 2018-02-04 2018-02-05 2018-02-06 2018-02-07 2018-02-08 2018-02-09 2018-02-10], bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-01 2018-02-02 2018-02-03 2018-02-04 2018-02-05 2018-02-06 2018-02-07 2018-02-08 2018-02-09 2018-02-10], bugs_opened_share_array: [9.523809523809524, 9.523809523809524, 9.523809523809524, 9.523809523809524, 9.30232558139535, 9.30232558139535, 9.30232558139535, 9.30232558139535, 9.30232558139535, 9.30232558139535])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-01 2018-02-02 2018-02-03 2018-02-04 2018-02-05 2018-02-06 2018-02-07 2018-02-08 2018-02-09 2018-02-10], queue_times: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], touch_times: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-01 2018-02-02 2018-02-03 2018-02-04 2018-02-05 2018-02-06 2018-02-07 2018-02-08 2018-02-09 2018-02-10], flow_efficiency_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.none, Date.new(2018, 2, 1), Date.new(2018, 2, 10), 'day') }

        it 'do the math and provides the correct information' do
          expect(report_data.all_projects).to eq []
          expect(report_data.x_axis).to eq []
          expect(report_data.demands_burnup_data.ideal_per_period).to eq []
          expect(report_data.demands_burnup_data.current_per_period).to eq []
          expect(report_data.demands_burnup_data.scope_per_period).to eq []
          expect(report_data.flow_pressure_data).to eq []
          expect(report_data.throughput_per_period).to eq([{ name: 'Upstream', data: [] }, { name: 'Downstream', data: [] }])
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
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }
      it { expect(report_data.hours_per_demand_per_week).to eq [0.0, 39.6, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 101.76, 0] }
    end
  end
end
