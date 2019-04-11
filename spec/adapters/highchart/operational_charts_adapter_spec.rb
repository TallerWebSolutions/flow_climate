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
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [2.6666666666666665, 5.333333333333333, 8.0, 10.666666666666666, 13.333333333333332, 16.0, 18.666666666666664, 21.333333333333332, 24.0, 26.666666666666664, 29.333333333333332, 32.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [40, 40, 38, 37, 37, 37, 37, 37, 37, 36, 32, 32]
            expect(report_data.flow_pressure_data).to eq [0.5508589181286555, 0.5540752923976613, 0.5477265515209218, 0.6461750305997556, 0.5634227831004941, 0.5190256807726105, 0.5044029644717614, 0.5324086283955498, 1.0439591848364482, 0.9595632663528035, 0.9064211512298214, 1.0808860552940027]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_demand.demand_id, fourth_demand.leadtime_in_days.to_f], [second_demand.demand_id, (second_demand.leadtime / 86_400).to_f], [first_demand.demand_id, (first_demand.leadtime / 86_400).to_f], [fifth_demand.demand_id, (fifth_demand.leadtime / 86_400).to_f], [third_demand.demand_id, (third_demand.leadtime / 86_400).to_f], [sixth_demand.demand_id, (sixth_demand.leadtime / 86_400).to_f], [first_bug.demand_id, (first_bug.leadtime / 86_400).to_f], [second_bug.demand_id, (second_bug.leadtime / 86_400).to_f], [third_bug.demand_id, (third_bug.leadtime / 86_400).to_f], [fourth_bug.demand_id, (fourth_bug.leadtime / 86_400).to_f]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], accumulated_bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-25 2018-03-04 2018-03-11 2018-03-18 2018-03-25 2018-04-01 2018-04-08 2018-04-15 2018-04-22 2018-04-29 2018-05-06 2018-05-13], bugs_opened_share_array: [9.090909090909092, 9.090909090909092, 9.523809523809524, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 10.0, 11.11111111111111, 11.11111111111111])
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
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [8.0, 16.0, 24.0, 32.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [2, 5, 5, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [40, 37, 33, 32]
            expect(report_data.flow_pressure_data).to eq [0.5572916666666672, 0.4271659178999298, 0.40977727859995317, 0.3073329589499649]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [0, 2, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [2, 1, 0, 5] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fifth_demand.demand_id, 4.0], [first_bug.demand_id, 0.5416666666666666], [first_demand.demand_id, 7.797361111111111], [fourth_bug.demand_id, 1.0], [second_demand.demand_id, 1.0], [sixth_demand.demand_id, 1.0], [fourth_demand.demand_id, 8.0], [third_demand.demand_id, 2.0], [second_bug.demand_id, 5.0], [third_bug.demand_id, 1.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.83 demanda(s)', '2.5 demanda(s)', '4.17 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [10.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], accumulated_bugs_opened_count_array: [4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 4])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], bugs_opened_share_array: [9.090909090909092, 9.75609756097561, 10.81081081081081, 11.11111111111111])
            expect(report_data.bugs_count_to_period).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], bugs_opened_count_array: [0, 0, 0, 0], bugs_closed_count_array: [0, 0, 0, 4])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], queue_times: [96.0, 0, 672.0, 0], touch_times: [96.0, 0, 240.0, 0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-02-28 2018-03-31 2018-04-30 2018-05-31], flow_efficiency_array: [50.0, 0, 26.31578947368421, 0])
            expect(report_data.aging_per_demand[:x_axis]).to eq %w[second_demand first_demand fifth_demand fourth_demand third_demand sixth_demand fourth_bug first_bug second_bug third_bug]
            expect(report_data.aging_per_demand[:data]).to eq [{ data: [33.0, 36.79736111111111, 51.0, 43.0, 29.0, 105.0, 105.0, 105.0, 105.0, 105.0], name: I18n.t('demands.charts.aging.series') }]
          end
        end

        context 'and using the day period interval' do
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, Date.new(2018, 3, 13), Date.new(2018, 4, 30), 'day') }

          before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }

          after { travel_back }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 3, 13), Date.new(2018, 4, 30))
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [0.673469387755102, 1.346938775510204, 2.020408163265306, 2.693877551020408, 3.36734693877551, 4.040816326530612, 4.714285714285714, 5.387755102040816, 6.061224489795918, 6.73469387755102, 7.408163265306122, 8.081632653061224, 8.755102040816325, 9.428571428571429, 10.10204081632653, 10.775510204081632, 11.448979591836734, 12.122448979591836, 12.795918367346939, 13.46938775510204, 14.142857142857142, 14.816326530612244, 15.489795918367346, 16.163265306122447, 16.83673469387755, 17.51020408163265, 18.183673469387756, 18.857142857142858, 19.53061224489796, 20.20408163265306, 20.877551020408163, 21.551020408163264, 22.224489795918366, 22.897959183673468, 23.57142857142857, 24.24489795918367, 24.918367346938773, 25.591836734693878, 26.26530612244898, 26.93877551020408, 27.612244897959183, 28.285714285714285, 28.959183673469386, 29.632653061224488, 30.30612244897959, 30.97959183673469, 31.653061224489793, 32.326530612244895, 33.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [2, 2, 3, 3, 3, 3, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [38, 38, 38, 38, 38, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 37, 36, 36, 36, 36, 33]
            expect(report_data.flow_pressure_data).to eq [0.9415204678362573, 0.9415204678362573, 0.9415204678362572, 0.9415204678362573, 0.9415204678362573, 0.9415204678362572, 0.8402195143029988, 0.764243799153055, 0.7051515762586542, 0.6578777979431336, 0.6191992520486168, 0.5869671304698527, 0.5596937968262832, 0.5409328234196339, 0.5246733131338711, 0.5104462416338287, 0.4978929432514383, 0.4867344558004247, 0.4767505459758335, 0.46776502713370144, 0.46533177187336644, 0.4631197216366983, 0.461100023594523, 0.45924863372252894, 0.4575453550402944, 0.4559730977951549, 0.45451730404965535, 0.4643005530429558, 0.4734090952091322, 0.4819104012308968, 0.48986323589641845, 0.49731901839534504, 0.504322935288276, 0.5109148570698582, 0.6430705364782519, 0.7678842336972903, 0.8859512445801646, 0.9978042022586769, 1.1039211108254707, 1.204732173963925, 1.300625624266357, 1.274420252260015, 1.2494337347655962, 1.2255829680663781, 1.2027922354426808, 1.180992404237405, 1.1601202254238432, 1.1401177207275133, 1.1245030733657273]
            expect(report_data.throughput_per_period).to eq([{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [0.0, 284.8], upstream: [0.0, 224.0] }, keys: [[2018.0, 3.0], [2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fifth_demand.demand_id, 4.0], [fourth_demand.demand_id, 8.0], [third_demand.demand_id, 2.0], [first_bug.demand_id, 0.5416666666666666], [sixth_demand.demand_id, 1.0], [second_bug.demand_id, 5.0], [third_bug.demand_id, 1.0], [fourth_bug.demand_id, 1.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 6.949999999999998
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 4.6000000000000005
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.4000000000000004
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [5.0, 2.0, 1.0]
            expect(report_data.throughput_bins).to eq ['0.33 demanda(s)', '1.0 demanda(s)', '1.67 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [6.0, 1.0, 1.0]
            expect(report_data.bugs_count_accumulated_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], accumulated_bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], accumulated_bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            expect(report_data.bugs_share_accumulated_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], bugs_opened_share_array: [9.523809523809524, 9.523809523809524, 9.523809523809524, 9.523809523809524, 9.523809523809524, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 9.75609756097561, 10.0, 10.0, 10.0, 10.0, 10.81081081081081])
            expect(report_data.queue_touch_count_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], queue_times: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 672.0], touch_times: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 240.0])
            expect(report_data.queue_touch_share_hash).to eq(dates_array: %w[2018-03-13 2018-03-14 2018-03-15 2018-03-16 2018-03-17 2018-03-18 2018-03-19 2018-03-20 2018-03-21 2018-03-22 2018-03-23 2018-03-24 2018-03-25 2018-03-26 2018-03-27 2018-03-28 2018-03-29 2018-03-30 2018-03-31 2018-04-01 2018-04-02 2018-04-03 2018-04-04 2018-04-05 2018-04-06 2018-04-07 2018-04-08 2018-04-09 2018-04-10 2018-04-11 2018-04-12 2018-04-13 2018-04-14 2018-04-15 2018-04-16 2018-04-17 2018-04-18 2018-04-19 2018-04-20 2018-04-21 2018-04-22 2018-04-23 2018-04-24 2018-04-25 2018-04-26 2018-04-27 2018-04-28 2018-04-29 2018-04-30], flow_efficiency_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421])
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
