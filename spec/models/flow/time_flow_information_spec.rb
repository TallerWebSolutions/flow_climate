# frozen_string_literal: true

RSpec.describe Flow::TimeFlowInformation, type: :model do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, company: company, customer: customer }

  describe '.initialize' do
    context 'with data' do
      it 'assigns the correct information' do
        travel_to Date.new(2018, 4, 26) do
          first_project = Fabricate :project, products: [product], customers: [customer], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10
          second_project = Fabricate :project, products: [product], customers: [customer], status: :waiting, name: 'second_project', start_date: Date.new(2018, 3, 13), end_date: Date.new(2018, 3, 21), qty_hours: 400, initial_scope: 10
          third_project = Fabricate :project, products: [product], customers: [customer], status: :maintenance, name: 'third_project', start_date: Date.new(2018, 3, 12), end_date: Date.new(2018, 5, 13), qty_hours: 800, initial_scope: 10

          queue_ongoing_stage = Fabricate :stage, company: company, stage_stream: :downstream, queue: false
          touch_ongoing_stage = Fabricate :stage, company: company, stage_stream: :downstream, queue: true
          first_stage = Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true
          second_stage = Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: false, end_point: true
          third_stage = Fabricate :stage, company: company, stage_stream: :downstream, projects: [first_project, second_project, third_project], queue: true, end_point: true
          fourth_stage = Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: false, end_point: true
          fifth_stage = Fabricate :stage, company: company, stage_stream: :upstream, projects: [first_project, second_project, third_project], queue: true, end_point: true

          first_demand = Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-19T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00')
          second_demand = Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.iso8601('2018-01-20T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00')
          third_demand = Fabricate :demand, product: product, project: second_project, external_id: 'third_demand', created_date: Time.zone.iso8601('2018-02-18T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-17T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00')
          fourth_demand = Fabricate :demand, product: product, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.iso8601('2018-02-03T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00')
          fifth_demand = Fabricate :demand, product: product, project: third_project, external_id: 'fifth_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-13T23:01:46-02:00')
          sixth_demand = Fabricate :demand, product: product, project: first_project, external_id: 'sixth_demand', created_date: Time.zone.iso8601('2018-01-15T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-04-29T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-04-30T23:01:46-02:00')

          Fabricate :demand_transition, stage: queue_ongoing_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-02-10T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-14T17:09:58-03:00')
          Fabricate :demand_transition, stage: touch_ongoing_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-03-10T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-03-14T17:09:58-03:00')

          first_transition = Fabricate :demand_transition, stage: first_stage, demand: first_demand, last_time_in: Time.zone.iso8601('2018-02-27T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-03-02T17:09:58-03:00')
          second_transition = Fabricate :demand_transition, stage: second_stage, demand: second_demand, last_time_in: Time.zone.iso8601('2018-02-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-10T17:09:58-03:00')
          fourth_transition = Fabricate :demand_transition, stage: fourth_stage, demand: fourth_demand, last_time_in: Time.zone.iso8601('2018-01-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-02-02T17:09:58-03:00')
          fifth_transition = Fabricate :demand_transition, stage: fifth_stage, demand: fifth_demand, last_time_in: Time.zone.iso8601('2018-03-08T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-02T17:09:58-03:00')
          Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.iso8601('2018-04-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-25T17:09:58-03:00')
          Fabricate :demand_transition, stage: third_stage, demand: third_demand, last_time_in: Time.zone.iso8601('2018-04-02T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-20T17:09:58-03:00')
          Fabricate :demand_transition, stage: queue_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.iso8601('2018-03-25T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-04T17:09:58-03:00')
          Fabricate :demand_transition, stage: touch_ongoing_stage, demand: sixth_demand, last_time_in: Time.zone.iso8601('2018-03-30T17:09:58-03:00'), last_time_out: Time.zone.iso8601('2018-04-04T17:09:58-03:00')

          Fabricate :demand_effort, demand: fifth_demand, demand_transition: fifth_transition, start_time_to_computation: Time.zone.iso8601('2018-02-22T17:09:58-03:00'), effort_value: 100
          Fabricate :demand_effort, demand: fourth_demand, demand_transition: fourth_transition, start_time_to_computation: Time.zone.iso8601('2018-02-08T17:09:58-03:00'), effort_value: 20

          Fabricate :demand_effort, demand: first_demand, demand_transition: first_transition, start_time_to_computation: Time.zone.iso8601('2018-02-21T17:09:58-03:00'), effort_value: 10
          Fabricate :demand_effort, demand: second_demand, demand_transition: second_transition, start_time_to_computation: Time.zone.iso8601('2018-02-02T17:09:58-03:00'), effort_value: 5

          time_flow_info = described_class.new(Demand.all)
          expect(time_flow_info.demands).to match_array Demand.all

          dates_array = TimeService.instance.weeks_between_of(Date.new(2018, 2, 20), Date.new(2018, 5, 13))

          time_flow_info.hours_flow_behaviour(dates_array.first)
          expect(time_flow_info.hours_delivered_upstream).to eq [120]
          expect(time_flow_info.hours_delivered_downstream).to eq [15]
          expect(time_flow_info.queue_time).to eq [0.0]
          expect(time_flow_info.touch_time).to eq [0.0]
          expect(time_flow_info.flow_efficiency).to eq [0]

          time_flow_info.hours_flow_behaviour(dates_array.second)
          expect(time_flow_info.hours_delivered_upstream).to eq [120.0, 0.0]
          expect(time_flow_info.hours_delivered_downstream).to eq [15, 0]
          expect(time_flow_info.queue_time).to eq [0.0, 96.0]
          expect(time_flow_info.touch_time).to eq [0.0, 96.0]
          expect(time_flow_info.flow_efficiency).to eq [0, 50.0]
          expect(time_flow_info.average_queue_time).to eq [0.0, 9.6]
          expect(time_flow_info.average_touch_time).to eq [0.0, 9.6]
        end
      end
    end

    context 'with no data' do
      let(:dates_array) { TimeService.instance.weeks_between_of(Date.new(2018, 2, 20), Date.new(2018, 5, 13)) }

      it 'assigns the correct information' do
        time_flow_info = described_class.new(Demand.all)
        expect(time_flow_info.demands).to eq []

        time_flow_info.hours_flow_behaviour(dates_array.first)
        expect(time_flow_info.hours_delivered_upstream).to eq []
        expect(time_flow_info.hours_delivered_downstream).to eq []
        expect(time_flow_info.queue_time).to eq []
        expect(time_flow_info.touch_time).to eq []
        expect(time_flow_info.flow_efficiency).to eq []
        expect(time_flow_info.average_queue_time).to eq []
        expect(time_flow_info.average_touch_time).to eq []
      end
    end
  end
end
