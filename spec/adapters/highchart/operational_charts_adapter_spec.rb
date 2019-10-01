# frozen_string_literal: true

RSpec.describe Highchart::OperationalChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customers: [customer], status: :executing, name: 'first_project', start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-04-22'), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, customers: [customer], status: :waiting, name: 'second_project', start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21'), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, customers: [customer], status: :maintenance, name: 'third_project', start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800, initial_scope: 10 }

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

    let!(:first_demand) { Fabricate :demand, project: first_project, demand_id: 'first_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-19T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, demand_id: 'second_demand', created_date: Time.zone.iso8601('2018-01-20T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, demand_id: 'third_demand', created_date: Time.zone.iso8601('2018-02-18T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-17T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, demand_id: 'fourth_demand', created_date: Time.zone.iso8601('2018-02-03T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, demand_id: 'fifth_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, demand_id: 'sixth_demand', created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:seventh_demand) { Fabricate :demand, project: first_project, demand_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, end_date: Project.all.map(&:end_date).max + 5.months, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, project: first_project, demand_id: 'first_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-30T10:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, project: first_project, demand_id: 'second_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-25T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, project: first_project, demand_id: 'third_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, project: first_project, demand_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }
    let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: fourth_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }
    let!(:fifth_item_assignment) { Fabricate :item_assignment, demand: fifth_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }
    let!(:sixth_item_assignment) { Fabricate :item_assignment, demand: sixth_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }
    let!(:seventh_item_assignment) { Fabricate :item_assignment, demand: seventh_demand, start_time: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), finish_time: nil }

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

    let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.iso8601('2018-02-27T17:30:58-03:00'), unblock_time: Time.zone.iso8601('2018-02-28T17:09:58-03:00'), active: true }
    let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 30.hours.ago }
    let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 1.day.ago }
    let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
    let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
    let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

    describe '.initialize' do
      before { travel_to Date.new(2018, 11, 19) }

      after { travel_back }

      context 'having projects' do
        context 'and using the week period interval' do
          subject(:report_data) { described_class.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 25), Date.new(2018, 3, 4), Date.new(2018, 3, 11), Date.new(2018, 3, 18), Date.new(2018, 3, 25), Date.new(2018, 4, 1), Date.new(2018, 4, 8), Date.new(2018, 4, 15), Date.new(2018, 4, 22), Date.new(2018, 4, 29), Date.new(2018, 5, 6), Date.new(2018, 5, 13)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 2, 2, 4, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5567068713450297, 0.5636659356725151, 0.5721354945827105, 0.6914066891631537, 0.6055391444339713, 0.5604651432650959, 0.5475944614229922, 0.5820546365037389, 1.163846545579081, 1.069684113243395, 1.0103188908273288, 1.203903427702829]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [['second_demand', 1.0], ['first_demand', 7.797361111111111], ['third_demand', 2.0], ['first_bug', 0.5416666666666666], ['sixth_demand', 1.0], ['fourth_bug', 1.0], ['third_bug', 1.0], ['second_bug', 5.0], ['seventh_demand', 30.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 6.818284722222221
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 3.8000000000000016
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 1.2000000000000002
            expect(report_data.leadtime_bins).to eq ['5.45 Dias', '15.27 Dias', '25.09 Dias']
            expect(report_data.leadtime_histogram_data).to eq [8.0, 0.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], accumulated_bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.bugs_count_to_period).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], bugs_opened_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], queue_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 672.0, 0], touch_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 240.0, 0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], flow_efficiency_array: [0, 50.0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421, 0])
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 13 }]
          end
        end

        context 'and using the month period interval' do
          subject(:report_data) { described_class.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'month') }

          before { travel_to Time.zone.local(2018, 5, 15, 10, 0, 0) }

          after { travel_back }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 28), Date.new(2018, 3, 31), Date.new(2018, 4, 30), Date.new(2018, 5, 31)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [10.5, 21.0, 31.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [2, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5622299382716055, 0.44218216281169204, 0.37415318790620744, 0.2806148909296556]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 2, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [2, 1, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [['second_demand', 1.0], ['first_demand', 7.797361111111111], ['third_demand', 2.0], ['first_bug', 0.5416666666666666], ['sixth_demand', 1.0], ['fourth_bug', 1.0], ['third_bug', 1.0], ['second_bug', 5.0], ['seventh_demand', 30.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 6.818284722222221
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 3.8000000000000016
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 1.2000000000000002
            expect(report_data.leadtime_bins).to eq ['5.45 Dias', '15.27 Dias', '25.09 Dias']
            expect(report_data.leadtime_histogram_data).to eq [8.0, 0.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], accumulated_bugs_opened_count_array: [4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.bugs_count_to_period).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], bugs_opened_count_array: [0, 0, 0, 0], bugs_closed_count_array: [0, 0, 4, 0])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], queue_times: [96.0, 0, 0, 672.0], touch_times: [96.0, 0, 0, 240.0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], flow_efficiency_array: [50.0, 0, 0, 26.31578947368421])
            expect(report_data.aging_per_demand[:x_axis]).to match_array %w[first_bug first_demand fourth_bug second_bug second_demand sixth_demand third_bug third_demand]
            expect(report_data.aging_per_demand[:data]).to eq [{ data: [33.0, 36.79736111111111, 29.0, 105.0, 105.0, 105.0, 105.0, 105.0], name: I18n.t('demands.charts.aging.series') }]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 13 }]
          end
        end

        context 'and using the day period interval' do
          before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

          after { travel_back }

          it 'does the math and provides the correct information' do
            report_data = described_class.new(Project.all, Date.new(2018, 2, 25), Date.new(2018, 5, 2), 'day')

            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 2, 25), Date.new(2018, 5, 2))
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [0.6268656716417911, 1.2537313432835822, 1.8805970149253732, 2.5074626865671643, 3.1343283582089554, 3.7611940298507465, 4.388059701492537, 5.014925373134329, 5.64179104477612, 6.268656716417911, 6.895522388059701, 7.522388059701493, 8.149253731343284, 8.776119402985074, 9.402985074626866, 10.029850746268657, 10.656716417910449, 11.28358208955224, 11.91044776119403, 12.537313432835822, 13.164179104477613, 13.791044776119403, 14.417910447761194, 15.044776119402986, 15.671641791044777, 16.29850746268657, 16.92537313432836, 17.55223880597015, 18.17910447761194, 18.80597014925373, 19.432835820895523, 20.059701492537314, 20.686567164179106, 21.313432835820898, 21.94029850746269, 22.56716417910448, 23.19402985074627, 23.82089552238806, 24.44776119402985, 25.074626865671643, 25.701492537313435, 26.328358208955226, 26.955223880597018, 27.582089552238806, 28.208955223880597, 28.83582089552239, 29.46268656716418, 30.08955223880597, 30.716417910447763, 31.343283582089555, 31.970149253731346, 32.59701492537314, 33.223880597014926, 33.85074626865672, 34.47761194029851, 35.1044776119403, 35.73134328358209, 36.35820895522388, 36.985074626865675, 37.61194029850746, 38.23880597014926, 38.865671641791046, 39.49253731343284, 40.11940298507463, 40.74626865671642, 41.37313432835821, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5567068713450297, 0.5575945071010865, 0.5585036612997144, 0.5594352305426872, 0.5603901655662253, 0.5613694755786921, 0.5623742330357044, 0.5634055789062414, 0.5644647284911111, 0.5655529778642223, 0.566671711017765, 0.567822407804932, 0.5690066527885982, 0.5702261451218802, 0.571482709607295, 0.5728351460769449, 0.5765753885087999, 0.5832273933366352, 0.5931777027548792, 0.607133150058408, 0.6231724167629744, 0.6425382284057704, 0.6725382916289838, 0.7234300042252509, 0.8371639600607302, 0.8141952083312537, 0.793184210357033, 0.773936501630463, 0.7562858969369035, 0.7400899724811836, 0.7252264568416074, 0.7115903395579423, 0.6990915545647504, 0.6876531319359396, 0.677209739233535, 0.6677065558498456, 0.6590984421567782, 0.6513493817405857, 0.6444321911156584, 0.6383285088448895, 0.6330290972042567, 0.6285345176697924, 0.624856281686085, 0.6220186389204921, 0.6200612614241192, 0.6190432410286454, 0.619049090832678, 0.620197933698395, 0.6226579909849735, 0.6266703484066534, 0.6325899774294922, 0.6409613477590769, 0.6526703499058578, 0.6692875656483419, 0.6939873876870589, 0.7347779855777403, 0.8239605089567591, 0.8124910201597488, 0.8015448446768152, 0.7911097405403889, 0.7811765511083363, 0.7717394846609849, 0.7627965298780063, 0.7543500563208846, 0.7464076745020286, 0.7389834711976078, 0.7320998041316401]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [39.6, 0.0, 284.8], upstream: [0.0, 0.0, 224.0] }, keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [['first_demand', 7.797361111111111], ['third_demand', 2.0], ['second_bug', 5.0], ['first_bug', 0.5416666666666666], ['sixth_demand', 1.0], ['fourth_bug', 1.0], ['third_bug', 1.0], ['seventh_demand', 30.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 6.958152777777776
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.400000000000002
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 1.5999999999999996
            expect(report_data.leadtime_bins).to eq ['5.45 Dias', '15.27 Dias', '25.09 Dias']
            expect(report_data.leadtime_histogram_data).to eq [7.0, 0.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [9.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-02-26 2018-02-27 2018-02-28 2018-03-01 2018-03-02 2018-03-03 2018-03-04 2018-03-05 2018-03-06 2018-03-07 2018-03-08 2018-03-09 2018-03-10 2018-03-11 2018-03-12 2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30 2018-05-01 2018-05-02], accumulated_bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-02-26 2018-02-27 2018-02-28 2018-03-01 2018-03-02 2018-03-03 2018-03-04 2018-03-05 2018-03-06 2018-03-07 2018-03-08 2018-03-09 2018-03-10 2018-03-11 2018-03-12 2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30 2018-05-01 2018-05-02], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-02-25 2018-02-26 2018-02-27 2018-02-28 2018-03-01 2018-03-02 2018-03-03 2018-03-04 2018-03-05 2018-03-06 2018-03-07 2018-03-08 2018-03-09 2018-03-10 2018-03-11 2018-03-12 2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30 2018-05-01 2018-05-02], queue_times: [0, 0, 96.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 672.0, 0], touch_times: [0, 0, 96.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 240.0, 0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-02-25 2018-02-26 2018-02-27 2018-02-28 2018-03-01 2018-03-02 2018-03-03 2018-03-04 2018-03-05 2018-03-06 2018-03-07 2018-03-08 2018-03-09 2018-03-10 2018-03-11 2018-03-12 2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30 2018-05-01 2018-05-02], flow_efficiency_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 13 }]
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { described_class.new(Project.none, Date.new(2018, 2, 1), Date.new(2018, 2, 10), 'day') }

        it 'does the math and provides the correct information' do
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
          expect(report_data.throughput_bins).to eq ['0.0 demanda(s)']
          expect(report_data.throughput_histogram_data).to eq [2.0]
          expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 0 }, { name: I18n.t('charts.scope.created'), y: 0 }]
        end
      end
    end

    describe '#hours_per_demand' do
      subject(:report_data) { described_class.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

      before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

      after { travel_back }

      it { expect(report_data.hours_per_demand).to eq [0.0, 19.8, 19.8, 9.9, 7.92, 7.92, 7.92, 7.92, 7.92, 7.92, 54.84, 54.84] }
    end

    describe '#hours_blocked_per_stage' do
      subject(:report_data) { described_class.new(Project.all, Time.zone.iso8601('2018-02-27T17:30:58-03:00').to_date, 1.day.from_now.to_date, 'week') }

      it { expect(report_data.hours_blocked_per_stage[:x_axis].count).to be_positive }
      it { expect(report_data.hours_blocked_per_stage[:data].count).to be_positive }
    end

    describe '#count_blocked_per_stage' do
      subject(:report_data) { described_class.new(Project.all, Time.zone.iso8601('2018-02-27T17:30:58-03:00').to_date, 1.day.from_now.to_date, 'week') }

      it { expect(report_data.count_blocked_per_stage[:x_axis].count).to be_positive }
      it { expect(report_data.count_blocked_per_stage[:data].count).to be_positive }
    end
  end
end
