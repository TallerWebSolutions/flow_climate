# frozen_string_literal: true

RSpec.describe Highchart::OperationalChartsAdapter, type: :data_object do
  before { travel_to Time.zone.local(2019, 10, 7, 18, 35, 0) }

  after { travel_back }

  shared_context 'demand data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customers: [customer], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, customers: [customer], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, customers: [customer], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_opened_demand) { Fabricate :demand, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }
    let!(:second_opened_demand) { Fabricate :demand, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }

    let!(:first_demand) { Fabricate :demand, project: first_project, demand_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, project: first_project, demand_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 21, 23, 1, 46), effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, project: second_project, demand_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), commitment_date: Time.zone.local(2018, 3, 17, 23, 1, 46), effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, demand_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46), commitment_date: nil, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, demand_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, project: first_project, demand_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:seventh_demand) { Fabricate :demand, project: first_project, demand_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, project: first_project, demand_id: 'first_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 30, 10, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, project: first_project, demand_id: 'second_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 25, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, project: first_project, demand_id: 'third_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, project: first_project, demand_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }

    let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
    let!(:second_item_assignment) { Fabricate :item_assignment, demand: second_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
    let!(:third_item_assignment) { Fabricate :item_assignment, demand: third_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
    let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: fourth_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
    let!(:fifth_item_assignment) { Fabricate :item_assignment, demand: fifth_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
    let!(:sixth_item_assignment) { Fabricate :item_assignment, demand: sixth_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }
    let!(:seventh_item_assignment) { Fabricate :item_assignment, demand: seventh_demand, start_time: Time.zone.local(2018, 1, 8, 17, 9, 58), finish_time: nil }

    let!(:queue_ongoing_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 14, 17, 9, 58) }
    let!(:touch_ongoing_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 3, 10, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 14, 17, 9, 58) }

    let!(:first_transition) { Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.local(2018, 2, 27, 17, 9, 58), last_time_out: Time.zone.local(2018, 3, 2, 17, 9, 58) }
    let!(:second_transition) { Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.local(2018, 2, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 10, 17, 9, 58) }
    let!(:third_transition) { Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.local(2018, 4, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 20, 17, 9, 58) }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: fourth_demand, last_time_in: Time.zone.local(2018, 1, 8, 17, 9, 58), last_time_out: Time.zone.local(2018, 2, 2, 17, 9, 58) }
    let!(:fifth_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: fifth_demand, last_time_in: Time.zone.local(2018, 3, 8, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 2, 17, 9, 58) }
    let!(:sixth_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 4, 2, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 25, 17, 9, 58) }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: queue_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 3, 25, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 4, 17, 9, 58) }
    let!(:eigth_transition) { Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.local(2018, 3, 30, 17, 9, 58), last_time_out: Time.zone.local(2018, 4, 4, 17, 9, 58) }

    let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: Time.zone.local(2018, 2, 27, 17, 30, 58), unblock_time: Time.zone.local(2018, 2, 28, 17, 9, 58), active: true }
    let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 30.hours.ago }
    let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 1.day.ago }
    let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
    let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
    let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

    let(:start_date) { Project.all.map(&:start_date).min }
    let(:end_date) { Project.all.map(&:end_date).max }
  end

  context 'having data' do
    include_context 'demand data'

    describe '.initialize' do
      context 'having projects' do
        context 'and using the week period interval' do
          subject(:report_data) { described_class.new(Project.all, start_date, end_date, 'week') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq TimeService.instance.weeks_between_of(Date.new(2018, 2, 23), Date.new(2018, 5, 13))
            expect(report_data.work_item_flow_information.ideal_per_period).to eq [3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0, 31.5, 35.0, 38.5, 42.0]
            expect(report_data.work_item_flow_information.accumulated_throughput).to eq [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5]
            expect(report_data.work_item_flow_information.scope_per_period).to eq [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 13 }]
          end
        end

        context 'and using the month period interval' do
          subject(:report_data) { described_class.new(Project.all, start_date, end_date, 'month') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq TimeService.instance.months_between_of(Date.new(2018, 2, 4), Date.new(2018, 5, 13))
            expect(report_data.work_item_flow_information.ideal_per_period).to eq [10.5, 21.0, 31.5, 42.0]
            expect(report_data.work_item_flow_information.accumulated_throughput).to eq [1, 1, 1, 5]
            expect(report_data.work_item_flow_information.scope_per_period).to eq [42, 42, 42, 42]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 13 }]
          end
        end

        context 'and using the day period interval' do
          it 'does the math and provides the correct information' do
            report_data = described_class.new(Project.all, start_date, end_date, 'day')

            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 2, 20), Date.new(2018, 5, 13))
            expect(report_data.work_item_flow_information.ideal_per_period).to eq [0.5060240963855421, 1.0120481927710843, 1.5180722891566263, 2.0240963855421685, 2.5301204819277108, 3.0361445783132526, 3.542168674698795, 4.048192771084337, 4.554216867469879, 5.0602409638554215, 5.566265060240964, 6.072289156626505, 6.578313253012047, 7.08433734939759, 7.590361445783132, 8.096385542168674, 8.602409638554215, 9.108433734939759, 9.6144578313253, 10.120481927710843, 10.626506024096384, 11.132530120481928, 11.638554216867469, 12.14457831325301, 12.650602409638553, 13.156626506024095, 13.662650602409638, 14.16867469879518, 14.674698795180722, 15.180722891566264, 15.686746987951807, 16.19277108433735, 16.69879518072289, 17.20481927710843, 17.710843373493976, 18.216867469879517, 18.72289156626506, 19.2289156626506, 19.734939759036145, 20.240963855421686, 20.746987951807228, 21.25301204819277, 21.75903614457831, 22.265060240963855, 22.771084337349397, 23.277108433734938, 23.78313253012048, 24.28915662650602, 24.795180722891565, 25.301204819277107, 25.807228915662648, 26.31325301204819, 26.819277108433734, 27.325301204819276, 27.831325301204817, 28.33734939759036, 28.8433734939759, 29.349397590361445, 29.855421686746986, 30.361445783132528, 30.86746987951807, 31.373493975903614, 31.879518072289155, 32.3855421686747, 32.89156626506024, 33.39759036144578, 33.903614457831324, 34.40963855421686, 34.91566265060241, 35.42168674698795, 35.92771084337349, 36.433734939759034, 36.93975903614457, 37.44578313253012, 37.95180722891566, 38.4578313253012, 38.963855421686745, 39.46987951807229, 39.97590361445783, 40.48192771084337, 40.98795180722891, 41.493975903614455, 42.0]
            expect(report_data.work_item_flow_information.accumulated_throughput).to eq [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
            expect(report_data.work_item_flow_information.scope_per_period).to eq [40, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 13 }]
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { described_class.new(Project.none, start_date, end_date, 'day') }

        it 'does the math and provides the correct information' do
          expect(report_data.all_projects).to eq []
          expect(report_data.x_axis).to eq []
          expect(report_data.work_item_flow_information.ideal_per_period).to eq []
          expect(report_data.work_item_flow_information.throughput_per_period).to eq []
          expect(report_data.work_item_flow_information.scope_per_period).to eq []
          expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 0 }, { name: I18n.t('charts.scope.created'), y: 0 }]
        end
      end
    end
  end
end
