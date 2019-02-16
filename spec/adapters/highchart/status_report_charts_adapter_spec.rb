# frozen_string_literal: true

RSpec.describe Highchart::StatusReportChartsAdapter, type: :data_object do
  context 'having projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, status: :executing, start_date: Time.zone.parse('2018-02-20'), end_date: Time.zone.parse('2018-04-22'), qty_hours: 1000 }
    let(:second_project) { Fabricate :project, customer: customer, status: :waiting, start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-04-21'), qty_hours: 400 }
    let(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800 }

    let(:first_stage) { Fabricate :stage, company: company, name: 'first_stage', stage_stream: :downstream, queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, name: 'second_stage', stage_stream: :downstream, queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, name: 'third_stage', stage_stream: :downstream, queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, name: 'fourth_stage', stage_stream: :upstream, queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, name: 'fifth_stage', stage_stream: :upstream, queue: true, end_point: true }

    let(:sixth_stage) { Fabricate :stage, company: company, name: 'sixth_stage', projects: [first_project, second_project, third_project], stage_stream: :upstream, end_point: false }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: first_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: second_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:third_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: third_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:fourth_stage_project_config) { Fabricate :stage_project_config, project: second_project, stage: fourth_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:fifth_stage_project_config) { Fabricate :stage_project_config, project: third_project, stage: fifth_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:opened_demands) { Fabricate.times(20, :demand, project: first_project, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), commitment_date: nil, end_date: nil) }
    let!(:first_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.iso8601('2018-02-10T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), leadtime: 2 * 86_400, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), leadtime: 3 * 86_400, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, created_date: Time.zone.iso8601('2018-02-15T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, created_date: Time.zone.iso8601('2018-02-05T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), leadtime: 1 * 86_400, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), leadtime: 4 * 86_400, effort_upstream: 56, effort_downstream: 25 }

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
        before { travel_to Time.zone.local(2019, 2, 15, 10, 0, 0) }
        after { travel_back }

        subject(:report_data) { Highchart::StatusReportChartsAdapter.new(Project.all, 'all') }

        it 'do the math and provides the correct information' do
          expect(report_data.all_projects).to match_array Project.all
          expect(report_data.all_projects_weeks).to eq [Date.new(2018, 2, 5), Date.new(2018, 2, 12), Date.new(2018, 2, 19), Date.new(2018, 2, 26), Date.new(2018, 3, 5), Date.new(2018, 3, 12), Date.new(2018, 3, 19), Date.new(2018, 3, 26), Date.new(2018, 4, 2), Date.new(2018, 4, 9), Date.new(2018, 4, 16), Date.new(2018, 4, 23), Date.new(2018, 4, 30), Date.new(2018, 5, 7)]
          expect(report_data.hours_burnup_per_week_data.ideal_per_period).to eq [157.14285714285714, 314.2857142857143, 471.42857142857144, 628.5714285714286, 785.7142857142857, 942.8571428571429, 1100.0, 1257.142857142857, 1414.2857142857142, 1571.4285714285713, 1728.5714285714284, 1885.7142857142858, 2042.857142857143, 2200.0]
          expect(report_data.hours_burnup_per_week_data.current_per_period).to eq [0, 0, 0.0, 0.0, 0.0, 0.1122e3, 0.2376e3, 0.2376e3, 0.2376e3, 0.2376e3, 0.2376e3, 0.2376e3, 0.2376e3, 0.2376e3]
          expect(report_data.hours_burnup_per_week_data.scope_per_period).to eq [2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0, 2200.0]
          expect(report_data.hours_burnup_per_month_data.ideal_per_period).to eq [550.0, 1100.0, 1650.0, 2200.0]
          expect(report_data.hours_burnup_per_month_data.current_per_period).to eq [0, 237.6, 237.6, 237.6]
          expect(report_data.hours_burnup_per_month_data.scope_per_period).to eq [2200.0, 2200.0, 2200.0, 2200.0]
          expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0] }])
          expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [25] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [5] }, { name: I18n.t('projects.show.scope_gap'), data: [110] }])
          expect(report_data.dates_to_montecarlo_duration).not_to be_empty
          expect(report_data.confidence_95_duration).to be_within(10).of(306)
          expect(report_data.confidence_80_duration).to be_within(10).of(286)
          expect(report_data.confidence_60_duration).to be_within(10).of(269)
          expect(report_data.deadline).to eq [{ data: [-277], name: 'Dias (restantes)' }, { color: '#F45830', data: [361], name: 'Tempo Decorrido' }]
          expect(report_data.hours_per_stage_upstream).to eq(xcategories: [sixth_stage.name], hours_per_stage: [1104.0])
          expect(report_data.hours_per_stage_downstream).to eq(xcategories: [], hours_per_stage: [])
          expect(report_data.cumulative_flow_diagram_upstream).to eq([{ name: fourth_stage.name, data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], marker: { enabled: false } }, { name: sixth_stage.name, data: [2, 2, 2, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5], marker: { enabled: false } }, { name: fifth_stage.name, data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], marker: { enabled: false } }])
          expect(report_data.cumulative_flow_diagram_downstream).to eq([{ name: second_stage.name, data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], marker: { enabled: false } }, { name: first_stage.name, data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], marker: { enabled: false } }, { name: third_stage.name, data: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], marker: { enabled: false } }])
        end
      end
      context 'having no projects' do
        subject(:report_data) { Highchart::StatusReportChartsAdapter.new(Project.none, 'all') }

        it 'return empty sets' do
          expect(report_data.all_projects).to eq []
          expect(report_data.all_projects_weeks).to eq []
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
          expect(report_data.deadline).to eq []
          expect(report_data.hours_per_stage_upstream).to eq(xcategories: [], hours_per_stage: [])
          expect(report_data.hours_per_stage_downstream).to eq(xcategories: [], hours_per_stage: [])
          expect(report_data.cumulative_flow_diagram_upstream).to eq []
          expect(report_data.cumulative_flow_diagram_downstream).to eq []
        end
      end
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      subject(:report_data) { Highchart::StatusReportChartsAdapter.new(Project.all, 'all') }

      it 'returns empty arrays' do
        expect(report_data.all_projects).to eq []
        expect(report_data.all_projects_weeks).to eq []
        expect(report_data.throughput_per_week).to eq([{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: [] }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: [] }])
        expect(report_data.delivered_vs_remaining).to eq([{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [0] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [0] }, { name: I18n.t('projects.show.scope_gap'), data: [0] }])
      end
    end
  end
end
