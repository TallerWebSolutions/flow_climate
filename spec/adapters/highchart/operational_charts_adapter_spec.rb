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
    let!(:seventh_demand) { Fabricate :demand, project: first_project, demand_id: 'seventh_demand', downstream: false, created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, end_date: Project.all.map(&:end_date).max + 5.months, effort_upstream: 56, effort_downstream: 25 }

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
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 25), Date.new(2018, 3, 4), Date.new(2018, 3, 11), Date.new(2018, 3, 18), Date.new(2018, 3, 25), Date.new(2018, 4, 1), Date.new(2018, 4, 8), Date.new(2018, 4, 15), Date.new(2018, 4, 22), Date.new(2018, 4, 29), Date.new(2018, 5, 6), Date.new(2018, 5, 13)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5567068713450297, 0.5636659356725151, 0.5592882723604883, 0.6817712724964871, 0.5978308111006378, 0.5540415321539848, 0.5420885090420399, 0.5772369281704055, 1.1595641381716737, 1.0658299465767285, 1.006815102948541, 1.2006916221472739]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [['second_demand', 1.0], ['first_demand', 7.797361111111111], ['fifth_demand', 4.0], ['fourth_demand', 8.0], ['third_demand', 2.0], ['sixth_demand', 1.0], ['third_bug', 1.0], ['second_bug', 5.0], ['first_bug', 0.5416666666666666], ['fourth_bug', 1.0], ['seventh_demand', 30.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['5.45 Dias', '15.27 Dias', '25.09 Dias']
            expect(report_data.leadtime_histogram_data).to eq [10.0, 0.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], accumulated_bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.bugs_count_to_period).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], bugs_opened_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], queue_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 672.0, 0], touch_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 240.0, 0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], flow_efficiency_array: [0, 50.0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421, 0])
          end
        end

        context 'and using the month period interval' do
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'month') }

          before { travel_to Time.zone.local(2018, 5, 15, 10, 0, 0) }

          after { travel_back }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq [Date.new(2018, 2, 28), Date.new(2018, 3, 31), Date.new(2018, 4, 30), Date.new(2018, 5, 31)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [10.5, 21.0, 31.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [2, 5, 5, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5706250000000005, 0.45286006871035966, 0.440795601362462, 0.3305967010218465]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 2, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [2, 1, 0, 5] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [['second_demand', 1.0], ['first_demand', 7.797361111111111], ['fifth_demand', 4.0], ['fourth_demand', 8.0], ['third_demand', 2.0], ['sixth_demand', 1.0], ['third_bug', 1.0], ['second_bug', 5.0], ['first_bug', 0.5416666666666666], ['fourth_bug', 1.0], ['seventh_demand', 30.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['5.45 Dias', '15.27 Dias', '25.09 Dias']
            expect(report_data.leadtime_histogram_data).to eq [10.0, 0.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], accumulated_bugs_opened_count_array: [4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.bugs_count_to_period).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], bugs_opened_count_array: [0, 0, 0, 0], bugs_closed_count_array: [0, 0, 0, 4])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], queue_times: [96.0, 0, 672.0, 0], touch_times: [96.0, 0, 240.0, 0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], flow_efficiency_array: [50.0, 0, 26.31578947368421, 0])
            expect(report_data.aging_per_demand[:x_axis]).to match_array %w[second_demand first_demand fifth_demand fourth_demand third_demand sixth_demand fourth_bug first_bug second_bug third_bug]
            expect(report_data.aging_per_demand[:data]).to eq [{ data: [33.0, 36.79736111111111, 51.0, 43.0, 29.0, 105.0, 105.0, 105.0, 105.0, 105.0], name: I18n.t('demands.charts.aging.series') }]
          end
        end

        context 'and using the day period interval' do
          before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

          after { travel_back }

          it 'does the math and provides the correct information' do
            report_data = Highchart::OperationalChartsAdapter.new(Project.all, Date.new(2018, 3, 13), Date.new(2018, 4, 30), 'day')

            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 3, 13), Date.new(2018, 4, 30))
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [0.8571428571428571, 1.7142857142857142, 2.571428571428571, 3.4285714285714284, 4.285714285714286, 5.142857142857142, 6.0, 6.857142857142857, 7.7142857142857135, 8.571428571428571, 9.428571428571429, 10.285714285714285, 11.142857142857142, 12.0, 12.857142857142856, 13.714285714285714, 14.571428571428571, 15.428571428571427, 16.285714285714285, 17.142857142857142, 18.0, 18.857142857142858, 19.71428571428571, 20.57142857142857, 21.428571428571427, 22.285714285714285, 23.142857142857142, 24.0, 24.857142857142854, 25.71428571428571, 26.57142857142857, 27.428571428571427, 28.285714285714285, 29.142857142857142, 30.0, 30.857142857142854, 31.71428571428571, 32.57142857142857, 33.42857142857142, 34.285714285714285, 35.14285714285714, 36.0, 36.857142857142854, 37.714285714285715, 38.57142857142857, 39.42857142857142, 40.285714285714285, 41.14285714285714, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [3, 3, 3, 3, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [1.0492202729044833, 1.0492202729044833, 1.0492202729044835, 1.0492202729044833, 1.0492202729044835, 1.0492202729044835, 0.9367700861348774, 0.8524324460576729, 0.7868365037754027, 0.7343597499495866, 0.6914242240921007, 0.6556446192108624, 0.6253695689267378, 0.604635680962022, 0.5866663113926018, 0.5709431130193592, 0.5570697026900273, 0.544737782397288, 0.5337039589774686, 0.5237735178996311, 0.5212305108744283, 0.518918686306062, 0.5168078899610319, 0.514872993311421, 0.5130928883937789, 0.5114497146236479, 0.509928257429082, 0.5211192433090778, 0.5315384370594188, 0.5412630178930703, 0.5503602064148734, 0.5588888206540638, 0.5669005491817881, 0.5744409995608227, 0.724262165807137, 0.8657599339286558, 0.9996091740436062, 1.1264137173104012, 1.2467154634865916, 1.361002122353972, 1.4697138222522124, 1.4400116412991173, 1.4116909571345382, 1.384657576795622, 1.3588256800273242, 1.334116909205474, 1.3104595754398731, 1.2877879639145053, 1.2700099782563863]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [0.0, 284.8], upstream: [0.0, 224.0] }, keys: [[2018.0, 3.0], [2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [['fifth_demand', 4.0], ['fourth_demand', 8.0], ['third_demand', 2.0], ['first_bug', 0.5416666666666666], ['sixth_demand', 1.0], ['fourth_bug', 1.0], ['third_bug', 1.0], ['second_bug', 5.0], ['seventh_demand', 30.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 6.949999999999998
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.6000000000000005
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.4000000000000004
            expect(report_data.leadtime_bins).to eq ['5.45 Dias', '15.27 Dias', '25.09 Dias']
            expect(report_data.leadtime_histogram_data).to eq [8.0, 0.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.33 demanda(s)', '1.0 demanda(s)', '1.67 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [6.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], accumulated_bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], queue_times: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 672.0], touch_times: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 240.0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], flow_efficiency_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421])
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.none, Date.new(2018, 2, 1), Date.new(2018, 2, 10), 'day') }

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
        end
      end
    end

    describe '#hours_per_demand' do
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Project.all.map(&:start_date).min, Project.all.map(&:end_date).max, 'week') }

      it { expect(report_data.hours_per_demand).to eq [0.0, 19.8, 19.8, 13.2, 7.92, 7.92, 7.92, 7.92, 7.92, 7.92, 54.84, 54.84] }
    end

    describe '#hours_blocked_per_stage' do
      subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Time.zone.iso8601('2018-02-27T17:30:58-03:00').to_date, 1.day.from_now.to_date, 'week') }

      it { expect(report_data.hours_blocked_per_stage[:x_axis].count).to be_positive }
      it { expect(report_data.hours_blocked_per_stage[:data].count).to be_positive }
    end
  end
end
