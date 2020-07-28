# frozen_string_literal: true

RSpec.describe Flow::TimeFlowInformations, type: :model do
  shared_context 'demand data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let(:first_project) { Fabricate :project, products: [product], customers: [customer], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10 }
    let(:second_project) { Fabricate :project, products: [product], customers: [customer], status: :waiting, name: 'second_project', start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21'), qty_hours: 400, initial_scope: 10 }
    let(:third_project) { Fabricate :project, products: [product], customers: [customer], status: :maintenance, name: 'third_project', start_date: Time.zone.parse('2018-03-12'), end_date: Time.zone.parse('2018-05-13'), qty_hours: 800, initial_scope: 10 }

    let(:queue_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: false }
    let(:touch_ongoing_stage) { Fabricate :stage, company: company, stage_stream: :downstream, queue: true }

    let(:first_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:second_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:third_stage) { Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }
    let(:fourth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true }
    let(:fifth_stage) { Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true }

    let!(:first_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: queue_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }
    let!(:second_stage_project_config) { Fabricate :stage_project_config, project: first_project, stage: touch_ongoing_stage, compute_effort: true, pairing_percentage: 60, stage_percentage: 100, management_percentage: 10 }

    let!(:first_opened_demand) { Fabricate :demand, product: product, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: nil }
    let!(:second_opened_demand) { Fabricate :demand, product: product, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: nil }

    let!(:first_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-19T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), effort_upstream: 10, effort_downstream: 5 }
    let!(:second_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.iso8601('2018-01-20T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), effort_upstream: 12, effort_downstream: 20 }
    let!(:third_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'third_demand', created_date: Time.zone.iso8601('2018-02-18T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-17T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), effort_upstream: 27, effort_downstream: 40 }
    let!(:fourth_demand) { Fabricate :demand, product: product, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.iso8601('2018-02-03T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), effort_upstream: 80, effort_downstream: 34 }
    let!(:fifth_demand) { Fabricate :demand, product: product, project: third_project, external_id: 'fifth_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:sixth_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'sixth_demand', created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:seventh_demand) { Fabricate :demand, product: product, project: first_project, external_id: 'seventh_demand', created_date: Project.all.map(&:end_date).max + 3.months, commitment_date: Project.all.map(&:end_date).max + 4.months, end_date: Project.all.map(&:end_date).max + 5.months, effort_upstream: 56, effort_downstream: 25 }

    let!(:first_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'first_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-30T10:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:second_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'second_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-25T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:third_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'third_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }
    let!(:fourth_bug) { Fabricate :demand, product: product, project: first_project, external_id: 'fourth_bug', demand_type: :bug, created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00'), effort_upstream: 56, effort_downstream: 25 }

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
  end

  describe '.initialize' do
    context 'having data' do
      include_context 'demand data'

      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns the correct information' do
        time_flow_info = described_class.new(Demand.all)
        expect(time_flow_info.demands).to match_array Demand.all

        time_flow_info.hours_flow_behaviour(dates_array.first)
        expect(time_flow_info.hours_delivered_upstream).to eq [12]
        expect(time_flow_info.hours_delivered_downstream).to eq [20]
        expect(time_flow_info.hours_per_demand).to eq [32]
        expect(time_flow_info.queue_time).to eq [0.0]
        expect(time_flow_info.touch_time).to eq [0.0]
        expect(time_flow_info.flow_efficiency).to eq [0]

        time_flow_info.hours_flow_behaviour(dates_array.second)
        expect(time_flow_info.hours_delivered_upstream).to eq [12.0, 10.0]
        expect(time_flow_info.hours_delivered_downstream).to eq [20, 5]
        expect(time_flow_info.hours_per_demand).to eq [32.0, 23.5]
        expect(time_flow_info.queue_time).to eq [0.0, 96.0]
        expect(time_flow_info.touch_time).to eq [0.0, 96.0]
        expect(time_flow_info.flow_efficiency).to eq [0, 50.0]
        expect(time_flow_info.average_queue_time).to eq [0.0, 7.384615384615385]
        expect(time_flow_info.average_touch_time).to eq [0.0, 7.384615384615385]
      end
    end

    context 'having no data' do
      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns the correct information' do
        time_flow_info = described_class.new(Demand.all)
        expect(time_flow_info.demands).to eq []

        time_flow_info.hours_flow_behaviour(dates_array.first)
        expect(time_flow_info.hours_delivered_upstream).to eq []
        expect(time_flow_info.hours_delivered_downstream).to eq []
        expect(time_flow_info.hours_per_demand).to eq []
        expect(time_flow_info.queue_time).to eq []
        expect(time_flow_info.touch_time).to eq []
        expect(time_flow_info.flow_efficiency).to eq []
        expect(time_flow_info.average_queue_time).to eq []
        expect(time_flow_info.average_touch_time).to eq []
      end
    end
  end
end
