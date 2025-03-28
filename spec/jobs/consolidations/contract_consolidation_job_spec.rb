# frozen_string_literal: true

RSpec.describe Consolidations::ContractConsolidationJob, type: :active_job do
  let(:first_user) { Fabricate :user }

  let!(:company) { Fabricate :company, users: [first_user] }
  let(:customer) { Fabricate :customer, company: company }
  let(:team) { Fabricate :team, company: company }

  describe '.perform_later' do
    it 'enqueues after calling perform_later with correct params' do
      contract = Fabricate(:contract)
      described_class.perform_later(contract)
      expect(described_class).to have_been_enqueued.with(contract).on_queue('low')
    end
  end

  context 'with demands' do
    it 'saves de consolidation' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        product = Fabricate :product, company: company, customer: customer
        contract = Fabricate :contract, customer: customer, product: product, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

        5.times { Fabricate :demand, customer: customer, contract: contract, created_date: 74.days.ago, commitment_date: 35.days.ago, end_date: 1.month.ago, effort_downstream: 20, effort_upstream: 10 }
        2.times { Fabricate :demand, customer: customer, contract: contract, created_date: 65.days.ago, commitment_date: 34.days.ago, end_date: 1.month.ago, effort_downstream: 40, effort_upstream: 13 }
        7.times { Fabricate :demand, customer: customer, contract: contract, created_date: 32.days.ago, commitment_date: 31.days.ago, end_date: 1.month.ago, effort_downstream: 10, effort_upstream: 20 }

        10.times { Fabricate :demand, customer: customer, contract: contract, created_date: 74.days.ago, commitment_date: 66.days.ago, end_date: 2.months.ago, effort_downstream: 20, effort_upstream: 10 }
        9.times { Fabricate :demand, customer: customer, contract: contract, created_date: 69.days.ago, commitment_date: 67.days.ago, end_date: 2.months.ago, effort_downstream: 40, effort_upstream: 13 }
        2.times { Fabricate :demand, customer: customer, contract: contract, created_date: 70.days.ago, commitment_date: 2.months.ago, end_date: 2.months.ago, effort_downstream: 10, effort_upstream: 20 }

        described_class.perform_now(contract)

        new_consolidations = Consolidations::ContractConsolidation.order(:consolidation_date)
        expect(new_consolidations.count).to eq 4

        expect(new_consolidations[0].operational_risk_value).to eq 1
        expect(new_consolidations[1].operational_risk_value).to be_within(0.2).of(0.5)
        expect(new_consolidations[2].operational_risk_value).to be_within(0.3).of(0.5)
        expect(new_consolidations[3].operational_risk_value).to be_within(0.3).of(0.9)
      end
    end
  end

  context 'with no demands' do
    it 'saves de consolidation' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        product = Fabricate :product, company: company, customer: customer
        contract = Fabricate :contract, customer: customer, product: product, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

        described_class.perform_now(contract)

        new_consolidations = Consolidations::ContractConsolidation.order(:consolidation_date)
        expect(new_consolidations.count).to eq 4

        expect(new_consolidations[0].operational_risk_value).to eq 1
        expect(new_consolidations[1].operational_risk_value).to eq 1
        expect(new_consolidations[2].operational_risk_value).to eq 1
        expect(new_consolidations[3].operational_risk_value).to eq 1
      end
    end
  end

  context 'with multiple contracts for the same product' do
    it 'consolidates hours only for the specific contract' do
      travel_to Time.zone.local(2023, 7, 8, 10, 0, 0) do
        product = Fabricate :product, company: company, customer: customer

        old_contract = Fabricate :contract,
                                 customer: customer,
                                 product: product,
                                 total_value: 100_000,
                                 total_hours: 3000,
                                 hours_per_demand: 15,
                                 start_date: 6.months.ago,
                                 end_date: 1.day.ago

        new_contract = Fabricate :contract,
                                 customer: customer,
                                 product: product,
                                 total_value: 80_000,
                                 total_hours: 1000,
                                 hours_per_demand: 20,
                                 start_date: Time.zone.today,
                                 end_date: 3.months.from_now

        old_demands = []
        4.times do |i|
          demand = Fabricate :demand,
                             customer: customer,
                             product: product,
                             contract: old_contract,
                             created_date: (5.months.ago + i.days),
                             commitment_date: (4.months.ago + i.days),
                             end_date: (3.months.ago + i.days)

          transition = Fabricate :demand_transition, demand: demand, last_time_in: (5.months.ago + i.days), last_time_out: (3.months.ago + i.days)
          item_assignment = Fabricate :item_assignment, demand: demand

          10.times do |j|
            effort_date = (5.months.ago + i.days + j.days)
            Fabricate :demand_effort,
                      demand: demand,
                      demand_transition: transition,
                      item_assignment: item_assignment,
                      start_time_to_computation: effort_date,
                      finish_time_to_computation: (effort_date + 10.hours),
                      effort_value: 10
          end

          old_demands << demand
        end

        new_demand = Fabricate :demand,
                               customer: customer,
                               product: product,
                               contract: new_contract,
                               created_date: Time.zone.today,
                               commitment_date: Time.zone.today

        transition = Fabricate :demand_transition, demand: new_demand, last_time_in: Time.zone.today, last_time_out: nil
        item_assignment = Fabricate :item_assignment, demand: new_demand

        5.times do |j|
          effort_date = (Time.zone.today + j.days)
          Fabricate :demand_effort,
                    demand: new_demand,
                    demand_transition: transition,
                    item_assignment: item_assignment,
                    start_time_to_computation: effort_date,
                    finish_time_to_computation: (effort_date + 10.hours),
                    effort_value: 10
        end

        described_class.perform_now(old_contract)
        described_class.perform_now(new_contract)

        old_contract_consolidations = Consolidations::ContractConsolidation.where(contract: old_contract).order(:consolidation_date)
        expect(old_contract_consolidations.last.consumed_hours).to eq 400

        new_contract_consolidations = Consolidations::ContractConsolidation.where(contract: new_contract).order(:consolidation_date)
        expect(new_contract_consolidations.last.consumed_hours).to eq 50

        expect(old_contract.remaining_hours).to eq 2600
        expect(new_contract.remaining_hours).to eq 950
      end
    end
  end
end
