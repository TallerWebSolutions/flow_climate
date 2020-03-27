# frozen_string_literal: true

RSpec.describe Highchart::OperationalChartsAdapter, type: :data_object do
  before { travel_to Time.zone.local(2019, 10, 7, 18, 35, 0) }

  after { travel_back }

  shared_context 'demand data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let(:first_project) { Fabricate :project, customers: [customer], products: [product], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, customers: [customer], products: [product], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, customers: [customer], products: [product], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10 }

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

    let!(:first_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), end_date: nil, effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil, effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), commitment_date: Time.zone.local(2018, 3, 17, 23, 1, 46), end_date: nil, effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46), commitment_date: nil, end_date: nil, effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, product: product, project: third_project, external_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, end_date: nil, effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: nil, effort_upstream: 56, effort_downstream: 25 }
    let!(:seventh_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, end_date: nil, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'first_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 30, 10, 1, 46), end_date: Time.zone.local(2018, 3, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'second_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 25, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'third_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }

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
          subject(:report_data) { described_class.new(Demand.all, start_date, end_date, 'week') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq TimeService.instance.weeks_between_of(Date.new(2018, 2, 23), Date.new(2018, 5, 13))
            expect(report_data.work_item_flow_information.ideal_per_period).to eq [3.3333333333333335, 6.666666666666667, 10.0, 13.333333333333334, 16.666666666666668, 20.0, 23.333333333333336, 26.666666666666668, 30.0, 33.333333333333336, 36.66666666666667, 40.0]
            expect(report_data.work_item_flow_information.accumulated_throughput).to eq [0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 5, 5]
            expect(report_data.work_item_flow_information.scope_per_period).to eq [40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 11 }]
          end
        end

        context 'and using the month period interval' do
          subject(:report_data) { described_class.new(Demand.all, start_date, end_date, 'month') }

          it 'do the math and provides the correct information' do
            expect(report_data.all_projects).to match_array [first_project, second_project, third_project]
            expect(report_data.x_axis).to eq TimeService.instance.months_between_of(Date.new(2018, 2, 4), Date.new(2018, 5, 13))
            expect(report_data.work_item_flow_information.ideal_per_period).to eq [10.0, 20.0, 30.0, 40.0]
            expect(report_data.work_item_flow_information.accumulated_throughput).to eq [0, 0, 1, 4]
            expect(report_data.work_item_flow_information.scope_per_period).to eq [40, 40, 40, 40]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 11 }]
          end
        end

        context 'and using the day period interval' do
          it 'does the math and provides the correct information' do
            report_data = described_class.new(Demand.all, start_date, end_date, 'day')

            expect(report_data.all_projects).to match_array Project.all
            expect(report_data.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 2, 20), Date.new(2018, 5, 13))
            expect(report_data.work_item_flow_information.ideal_per_period).to eq [0.4819277108433735, 0.963855421686747, 1.4457831325301205, 1.927710843373494, 2.4096385542168672, 2.891566265060241, 3.3734939759036147, 3.855421686746988, 4.337349397590361, 4.8192771084337345, 5.301204819277109, 5.783132530120482, 6.265060240963855, 6.746987951807229, 7.228915662650603, 7.710843373493976, 8.19277108433735, 8.674698795180722, 9.156626506024097, 9.638554216867469, 10.120481927710843, 10.602409638554217, 11.08433734939759, 11.566265060240964, 12.048192771084338, 12.53012048192771, 13.012048192771084, 13.493975903614459, 13.975903614457831, 14.457831325301205, 14.939759036144578, 15.421686746987952, 15.903614457831326, 16.3855421686747, 16.867469879518072, 17.349397590361445, 17.83132530120482, 18.313253012048193, 18.795180722891565, 19.277108433734938, 19.759036144578314, 20.240963855421686, 20.72289156626506, 21.204819277108435, 21.686746987951807, 22.16867469879518, 22.650602409638555, 23.132530120481928, 23.6144578313253, 24.096385542168676, 24.57831325301205, 25.06024096385542, 25.542168674698797, 26.02409638554217, 26.50602409638554, 26.987951807228917, 27.46987951807229, 27.951807228915662, 28.433734939759034, 28.91566265060241, 29.397590361445783, 29.879518072289155, 30.36144578313253, 30.843373493975903, 31.325301204819276, 31.80722891566265, 32.28915662650602, 32.7710843373494, 33.25301204819277, 33.734939759036145, 34.21686746987952, 34.69879518072289, 35.18072289156626, 35.66265060240964, 36.144578313253014, 36.626506024096386, 37.10843373493976, 37.59036144578313, 38.0722891566265, 38.554216867469876, 39.036144578313255, 39.51807228915663, 40.0]
            expect(report_data.work_item_flow_information.accumulated_throughput).to eq [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
            expect(report_data.work_item_flow_information.scope_per_period).to eq [38, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40]
            expect(report_data.scope_uncertainty).to eq [{ name: I18n.t('charts.scope.uncertainty'), y: 30 }, { name: I18n.t('charts.scope.created'), y: 11 }]
          end
        end
      end

      context 'having no projects' do
        subject(:report_data) { described_class.new(Demand.none, start_date, end_date, 'day') }

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
