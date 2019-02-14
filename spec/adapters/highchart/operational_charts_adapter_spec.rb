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
        context 'and filtering by all periods' do
          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'all') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to eq Project.all
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 1, 15), Date.new(2018, 1, 22), Date.new(2018, 1, 29), Date.new(2018, 2, 5), Date.new(2018, 2, 12), Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [2.4705882352941178, 4.9411764705882355, 7.411764705882353, 9.882352941176471, 12.352941176470589, 14.823529411764707, 17.294117647058826, 19.764705882352942, 22.235294117647058, 24.705882352941178, 27.176470588235297, 29.647058823529413, 32.11764705882353, 34.58823529411765, 37.05882352941177, 39.529411764705884, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [0, 0, 0, 0, 0, 1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [35, 38, 38, 39, 39, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5039255845707459, 0.51194743130227, 0.5146213802127781, 0.5252176139272914, 0.5315753541559993, 0.5419866871479775, 0.5516726403823178, 0.5600000304781411, 0.5686184868212517, 0.6672328286153171, 0.6311578590380433, 0.6076618998854022, 0.5993802152788328, 0.622893873371161, 0.5919496257284276, 0.5698337265013532, 0.5643253000124782]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]], data: { upstream: [0.0, 0.0, 224.0], downstream: [39.6, 0.0, 284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_demand.demand_id, fourth_demand.leadtime_in_days.to_f], [second_demand.demand_id, (second_demand.leadtime / 86_400).to_f], [first_demand.demand_id, (first_demand.leadtime / 86_400).to_f], [fifth_demand.demand_id, (fifth_demand.leadtime / 86_400).to_f], [third_demand.demand_id, (third_demand.leadtime / 86_400).to_f], [sixth_demand.demand_id, (sixth_demand.leadtime / 86_400).to_f], [first_bug.demand_id, (first_bug.leadtime / 86_400).to_f], [second_bug.demand_id, (second_bug.leadtime / 86_400).to_f], [third_bug.demand_id, (third_bug.leadtime / 86_400).to_f], [fourth_bug.demand_id, (fourth_bug.leadtime / 86_400).to_f]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.36 demanda(s)', '1.07 demanda(s)', '1.79 demanda(s)', '2.5 demanda(s)', '3.21 demanda(s)', '3.93 demanda(s)', '4.64 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [40.0, 3.0, 1.0, 0.0, 0.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-01-15 2018-01-22 2018-01-29 2018-02-05 2018-02-12 2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-01-15 2018-01-22 2018-01-29 2018-02-05 2018-02-12 2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [10.256410256410255, 9.523809523809524, 9.523809523809524, 9.30232558139535, 9.30232558139535, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-01-15 2018-01-22 2018-01-29 2018-02-05 2018-02-12 2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 0, 0, 0, 0, 0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 672.0, 0], touch_times: [0, 0, 0, 0, 0, 0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 240.0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-01-15 2018-01-22 2018-01-29 2018-02-05 2018-02-12 2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 0, 0, 0, 0, 0, 50.0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421, 0])
          end
        end
        context 'and filtering by last month' do
          before { travel_to Time.zone.local(2018, 5, 15, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'month') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, third_project]
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [6.0, 12.0, 18.0, 24.0, 30.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [3, 3, 3, 8, 8]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [30, 30, 30, 30, 30]
            expect(report_data.flow_pressure_data).to eq [0.75, 1.0714285714285714, 0.7936507936507936, 0.6845238095238095, 0.6904761904761905]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(keys: [[2018.0, 5.0]], data: { upstream: [224.0], downstream: [284.8] })
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[fourth_bug.demand_id, 1.0], [third_bug.demand_id, 1.0], [second_bug.demand_id, 5.0], [first_bug.demand_id, 0.5416666666666666], [sixth_demand.demand_id, 1.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 4.199999999999999
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 1.8000000000000007
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 1.0
            expect(report_data.leadtime_bins).to eq ['1.66 Dias', '3.89 Dias']
            expect(report_data.leadtime_histogram_data).to eq [4.0, 1.0]
            expect(report_data.throughput_bins).to eq ['1.25 demanda(s)', '3.75 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [5.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 4, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [11.76470588235294, 11.76470588235294, 11.76470588235294, 11.76470588235294, 11.76470588235294])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0, 0, 0, 672.0, 0], touch_times: [0, 0, 0, 240.0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 0, 0, 26.31578947368421, 0])
          end
        end

        context 'and filtering by quarter' do
          before { travel_to Time.zone.local(2018, 5, 21, 10, 0, 0) }
          after { travel_back }

          subject(:report_data) { Highchart::OperationalChartsAdapter.new(Project.all, 'quarter') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.all_projects_weeks).to eq [Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
            expect(report_data.demands_burnup_data.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.demands_burnup_data.current_per_period).to eq [1, 2, 2, 3, 5, 5, 5, 5, 5, 5, 10, 10]
            expect(report_data.demands_burnup_data.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.flow_pressure_data).to eq [0.5940433521078682, 0.601915855948114, 0.607374491015044, 0.6149224026528174, 0.8028903030746348, 0.71414327977308, 0.6620094325492614, 0.6417582534806037, 0.6736263840462509, 0.6221367615146416, 0.5872238957492414, 0.5779711107860109]
            expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 5, 0] }])
            expect(report_data.effort_hours_per_month).to eq(data: { downstream: [39.6, 0.0, 284.8], upstream: [0.0, 0.0, 224.0] }, keys: [[2018.0, 2.0], [2018.0, 3.0], [2018.0, 5.0]])
            expect(report_data.lead_time_control_chart[:dispersion_source]).to match_array [[second_demand.demand_id, 1.0], [first_demand.demand_id, 7.797361111111111], [fifth_demand.demand_id, 4.0], [fourth_demand.demand_id, 8.0], [third_demand.demand_id, 2.0], [first_bug.demand_id, 0.5416666666666666], [sixth_demand.demand_id, 1.0], [second_bug.demand_id, 5.0], [third_bug.demand_id, 1.0], [fourth_bug.demand_id, 1.0]]
            expect(report_data.lead_time_control_chart[:percentile_95_data]).to eq 7.9088125
            expect(report_data.lead_time_control_chart[:percentile_80_data]).to eq 5.559472222222222
            expect(report_data.lead_time_control_chart[:percentile_60_data]).to eq 2.799999999999999
            expect(report_data.leadtime_bins).to eq ['1.78 Dias', '4.27 Dias', '6.76 Dias']
            expect(report_data.leadtime_histogram_data).to eq [6.0, 2.0, 2.0]
            expect(report_data.throughput_bins).to eq ['0.63 demanda(s)', '1.88 demanda(s)', '3.13 demanda(s)', '4.38 demanda(s)']
            expect(report_data.throughput_histogram_data).to eq [12.0, 1.0, 0.0, 1.0]
            expect(report_data.weeekly_bugs_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_count_array: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4], bugs_closed_count_array: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4])
            expect(report_data.weeekly_bugs_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], bugs_opened_share_array: [8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043, 8.695652173913043])
            expect(report_data.weekly_queue_touch_count_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], queue_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 672.0, 0], touch_times: [0.0, 96.0, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 240.0, 0])
            expect(report_data.weekly_queue_touch_share_hash).to eq(dates_array: %w[2018-02-19 2018-02-26 2018-03-05 2018-03-12 2018-03-19 2018-03-26 2018-04-02 2018-04-09 2018-04-16 2018-04-23 2018-04-30 2018-05-07], flow_efficiency_array: [0, 50.0, 0, 0, 0, 0, 0, 0, 0, 0, 26.31578947368421, 0])
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
      it { expect(report_data.hours_per_demand_per_week).to eq [0, 0, 0, 0, 0, 0.0, 39.6, 0, 0.0, 0.0, 0, 0, 0, 0, 0, 101.76, 0] }
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
