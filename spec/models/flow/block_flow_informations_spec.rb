# frozen_string_literal: true

RSpec.describe Flow::BlockFlowInformations, type: :model do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer }

  describe '.initialize' do
    context 'with data' do
      it 'assigns the correct information' do
        travel_to Time.zone.local(2019, 10, 11, 18, 35, 0) do
          first_project = Fabricate :project, products: [product], customers: [customer], status: :executing, name: 'first_project', start_date: Date.new(2018, 2, 20), end_date: Date.new(2018, 4, 22), qty_hours: 1000, initial_scope: 10
          second_project = Fabricate :project, products: [product], customers: [customer], status: :waiting, name: 'second_project', start_date: Time.zone.parse('2018-03-13'), end_date: Time.zone.parse('2018-03-21'), qty_hours: 400, initial_scope: 10

          Fabricate :demand, product: product, project: first_project, demand_title: 'first_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: nil
          Fabricate :demand, product: product, project: first_project, demand_title: 'second_opened_demand', created_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: nil

          first_demand = Fabricate :demand, product: product, project: first_project, external_id: 'first_demand', created_date: Time.zone.iso8601('2018-01-21T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-19T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), effort_upstream: 10, effort_downstream: 5
          second_demand = Fabricate :demand, product: product, project: first_project, external_id: 'second_demand', created_date: Time.zone.iso8601('2018-01-20T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-02-21T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-02-22T23:01:46-02:00'), effort_upstream: 12, effort_downstream: 20
          third_demand = Fabricate :demand, product: product, project: second_project, external_id: 'third_demand', created_date: Time.zone.iso8601('2018-02-18T23:01:46-02:00'), commitment_date: Time.zone.iso8601('2018-03-17T23:01:46-02:00'), end_date: Time.zone.iso8601('2018-03-19T23:01:46-02:00'), effort_upstream: 27, effort_downstream: 40
          fourth_demand = Fabricate :demand, product: product, project: second_project, external_id: 'fourth_demand', created_date: Time.zone.iso8601('2018-02-03T23:01:46-02:00'), commitment_date: nil, end_date: Time.zone.iso8601('2018-03-18T23:01:46-02:00'), effort_upstream: 80, effort_downstream: 34

          Fabricate :demand_block, demand: first_demand, block_time: Time.zone.iso8601('2018-02-27T17:30:58-03:00'), unblock_time: Time.zone.iso8601('2018-02-28T17:09:58-03:00'), active: true
          Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 30.hours.ago
          Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 1.day.ago
          Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday
          Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago
          Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today

          dates_array = TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max)

          block_flow_info = described_class.new(Demand.all)
          expect(block_flow_info.demands).to match_array Demand.all

          block_flow_info.blocks_flow_behaviour(dates_array.first)
          expect(block_flow_info.blocks_count).to eq [4]
          expect(block_flow_info.blocks_time).to eq [12.0]

          block_flow_info.blocks_flow_behaviour(dates_array.second)
          expect(block_flow_info.blocks_count).to eq [4, 0]
          expect(block_flow_info.blocks_time).to eq [12, 0]
        end
      end
    end

    context 'with no data' do
      let(:dates_array) { TimeService.instance.weeks_between_of(Project.all.map(&:start_date).min, Project.all.map(&:end_date).max) }

      it 'assigns the correct information' do
        block_flow_info = described_class.new(Demand.all)

        expect(block_flow_info.demands).to eq []

        expect(block_flow_info.blocks_count).to eq []
        expect(block_flow_info.blocks_time).to eq []
      end
    end
  end
end
