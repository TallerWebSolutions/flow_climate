# frozen_string_literal: true

RSpec.describe Flow::WorkItemFlowInformations, type: :model do
  before { travel_to Time.zone.local(2019, 10, 7, 18, 35, 0) }

  shared_context 'demand data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }

    let(:first_project) { Fabricate :project, products: [product], customers: [customer], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, products: [product], customers: [customer], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, products: [product], customers: [customer], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_opened_demand) { Fabricate :demand, product: product, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }
    let!(:second_opened_demand) { Fabricate :demand, product: product, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.local(2018, 2, 21, 23, 1, 46), end_date: nil }

    let!(:first_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 19, 23, 1, 46), effort_upstream: 10, effort_downstream: 5, demand_tags: %w[aaa ccc sbbrubles] }
    let!(:second_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.local(2018, 1, 20, 23, 1, 46), commitment_date: Time.zone.local(2018, 2, 21, 23, 1, 46), effort_upstream: 12, effort_downstream: 20, demand_tags: %w[sbbrubles] }
    let!(:third_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'third_demand', created_date: Time.zone.local(2018, 2, 18, 23, 1, 46), commitment_date: Time.zone.local(2018, 3, 17, 23, 1, 46), effort_upstream: 27, effort_downstream: 40, demand_tags: %w[ccc] }
    let!(:fourth_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.local(2018, 2, 3, 23, 1, 46), commitment_date: nil, effort_upstream: 80, effort_downstream: 34, demand_tags: %w[aaa ccc sbbrubles] }
    let!(:fifth_demand) { Fabricate :demand, product: product, project: third_project, external_id: 'fifth_demand', created_date: Time.zone.local(2018, 1, 21, 23, 1, 46), commitment_date: nil, effort_upstream: 56, effort_downstream: 25, demand_tags: %w[ccc] }
    let!(:sixth_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'sixth_demand', created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 29, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
    let!(:seventh_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'first_bug', demand_type: :bug, created_date: Time.zone.local(2018, 1, 15, 23, 1, 46), commitment_date: Time.zone.local(2018, 4, 30, 10, 1, 46), end_date: Time.zone.local(2018, 4, 30, 23, 1, 46), effort_upstream: 56, effort_downstream: 25 }
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
  end

  describe '.initialize' do
    context 'with data' do
      include_context 'demand data'

      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns the correct information' do
        item_flow_info = described_class.new(Demand.all, 10, dates_array.length, dates_array.last, 'week')
        expect(item_flow_info.demands).to match_array Demand.all
        expect(item_flow_info.uncertain_scope).to eq 10
        expect(item_flow_info.current_scope).to eq 22
        expect(item_flow_info.period_size).to eq 12.0

        item_flow_info.work_items_flow_behaviour(dates_array.first, dates_array.first, 0, true)
        expect(item_flow_info.scope_per_period).to eq [22]
        expect(item_flow_info.ideal_per_period).to eq [1.8333333333333333]
        expect(item_flow_info.throughput_per_period).to eq [0]
        expect(item_flow_info.accumulated_throughput).to eq [0]
        expect(item_flow_info.accumulated_bugs_opened_data_array).to eq [4]
        expect(item_flow_info.accumulated_bugs_closed_data_array).to eq [0]
        expect(item_flow_info.bugs_opened_data_array).to eq [4]
        expect(item_flow_info.bugs_closed_data_array).to eq [0]
        expect(item_flow_info.bugs_share_data_array).to eq [33.33333333333333]
        expect(item_flow_info.upstream_total_delivered).to eq [0]
        expect(item_flow_info.upstream_delivered_per_period).to eq [0]
        expect(item_flow_info.downstream_total_delivered).to eq [0]
        expect(item_flow_info.downstream_delivered_per_period).to eq [0]
        expect(item_flow_info.throughput_array_for_monte_carlo).to eq [0]

        item_flow_info.work_items_flow_behaviour(dates_array.first, dates_array.second, 1, true)
        expect(item_flow_info.scope_per_period).to eq [22, 22]
        expect(item_flow_info.ideal_per_period).to eq [1.8333333333333333, 3.6666666666666665]
        expect(item_flow_info.throughput_per_period).to eq [0, 1]
        expect(item_flow_info.accumulated_throughput).to eq [0, 1]
        expect(item_flow_info.accumulated_bugs_opened_data_array).to eq [4, 4]
        expect(item_flow_info.accumulated_bugs_closed_data_array).to eq [0, 0]
        expect(item_flow_info.bugs_opened_data_array).to eq [4, 0]
        expect(item_flow_info.bugs_closed_data_array).to eq [0, 0]
        expect(item_flow_info.bugs_share_data_array).to eq [33.33333333333333, 33.33333333333333]
        expect(item_flow_info.upstream_total_delivered).to eq [0, 0]
        expect(item_flow_info.upstream_delivered_per_period).to eq [0, 0]
        expect(item_flow_info.downstream_total_delivered).to eq [0, 1]
        expect(item_flow_info.downstream_delivered_per_period).to eq [0, 1]
        expect(item_flow_info.throughput_array_for_monte_carlo).to eq [0, 1]

        item_flow_info.work_items_flow_behaviour(dates_array.first, dates_array.second, 1, false)
        expect(item_flow_info.scope_per_period).to eq [22, 22, 22]
        expect(item_flow_info.ideal_per_period).to eq [1.8333333333333333, 3.6666666666666665, 3.6666666666666665]
        expect(item_flow_info.throughput_per_period).to eq [0, 1]
        expect(item_flow_info.accumulated_throughput).to eq [0, 1]
        expect(item_flow_info.accumulated_bugs_opened_data_array).to eq [4, 4]
        expect(item_flow_info.accumulated_bugs_closed_data_array).to eq [0, 0]
        expect(item_flow_info.bugs_opened_data_array).to eq [4, 0]
        expect(item_flow_info.bugs_closed_data_array).to eq [0, 0]
        expect(item_flow_info.bugs_share_data_array).to eq [33.33333333333333, 33.33333333333333]
        expect(item_flow_info.upstream_total_delivered).to eq [0, 0]
        expect(item_flow_info.upstream_delivered_per_period).to eq [0, 0]
        expect(item_flow_info.downstream_total_delivered).to eq [0, 1]
        expect(item_flow_info.downstream_delivered_per_period).to eq [0, 1]
        expect(item_flow_info.throughput_array_for_monte_carlo).to eq [0, 1]

        expect(item_flow_info.demands_tags_hash.to_h).to eq({ ccc: 4, sbbrubles: 3, aaa: 2 }.stringify_keys)
      end
    end

    context 'with no data' do
      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns empty information' do
        item_flow_info = described_class.new(Demand.all, 10, dates_array.length, dates_array.last, 'week')

        item_flow_info.work_items_flow_behaviour(dates_array.first, dates_array.first, 0, true)

        expect(item_flow_info.demands).to eq []

        expect(item_flow_info.scope_per_period).to eq []
        expect(item_flow_info.ideal_per_period).to eq []
        expect(item_flow_info.throughput_per_period).to eq []
        expect(item_flow_info.accumulated_throughput).to eq []
        expect(item_flow_info.accumulated_bugs_opened_data_array).to eq []
        expect(item_flow_info.accumulated_bugs_closed_data_array).to eq []
        expect(item_flow_info.bugs_opened_data_array).to eq []
        expect(item_flow_info.bugs_closed_data_array).to eq []
        expect(item_flow_info.bugs_share_data_array).to eq []
        expect(item_flow_info.upstream_total_delivered).to eq []
        expect(item_flow_info.upstream_delivered_per_period).to eq []
        expect(item_flow_info.downstream_total_delivered).to eq []
        expect(item_flow_info.downstream_delivered_per_period).to eq []
        expect(item_flow_info.uncertain_scope).to eq 0
        expect(item_flow_info.current_scope).to eq 0
        expect(item_flow_info.period_size).to eq 0
      end
    end

    context 'with no end_sample_date' do
      it 'uses the current date as end sample date' do
        Fabricate :demand
        demands = Demand.all
        expect(demands).to receive(:opened_before_date).with(Time.zone.today).once.and_return(demands)
        described_class.new(demands, 10, 3.days.ago, nil, 'week')
      end
    end
  end
end
