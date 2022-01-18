# frozen_string_literal: true

RSpec.describe Consolidations::ContractConsolidationJob, type: :active_job do
  let(:first_user) { Fabricate :user }

  let!(:company) { Fabricate :company, users: [first_user] }
  let(:customer) { Fabricate :customer, company: company }
  let(:team) { Fabricate :team, company: company }

  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later
      expect(described_class).to have_been_enqueued.on_queue('consolidations')
    end
  end

  context 'with demands' do
    it 'saves de consolidation' do
      travel_to Time.zone.local(2020, 7, 8, 10, 0, 0) do
        product = Fabricate :product, company: company, customer: customer
        contract = Fabricate :contract, customer: customer, product: product, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

        5.times { Fabricate :demand, customer: customer, contract: contract, created_date: 74.days.ago, commitment_date: 35.days.ago, end_date: 1.month.ago, effort_downstream: 200, effort_upstream: 10 }
        2.times { Fabricate :demand, customer: customer, contract: contract, created_date: 65.days.ago, commitment_date: 34.days.ago, end_date: 1.month.ago, effort_downstream: 400, effort_upstream: 130 }
        7.times { Fabricate :demand, customer: customer, contract: contract, created_date: 32.days.ago, commitment_date: 31.days.ago, end_date: 1.month.ago, effort_downstream: 100, effort_upstream: 20 }

        10.times { Fabricate :demand, customer: customer, contract: contract, created_date: 74.days.ago, commitment_date: 66.days.ago, end_date: 2.months.ago, effort_downstream: 200, effort_upstream: 10 }
        9.times { Fabricate :demand, customer: customer, contract: contract, created_date: 69.days.ago, commitment_date: 67.days.ago, end_date: 2.months.ago, effort_downstream: 400, effort_upstream: 130 }
        2.times { Fabricate :demand, customer: customer, contract: contract, created_date: 70.days.ago, commitment_date: 2.months.ago, end_date: 2.months.ago, effort_downstream: 100, effort_upstream: 20 }

        described_class.perform_now(contract)

        new_consolidations = Consolidations::ContractConsolidation.all.order(:consolidation_date)
        expect(new_consolidations.count).to eq 4

        expect(new_consolidations[0].operational_risk_value).to eq 1
        expect(new_consolidations[1].operational_risk_value).to be_within(0.2).of(0.8)
        expect(new_consolidations[2].operational_risk_value).to be_within(0.3).of(0.9)
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

        new_consolidations = Consolidations::ContractConsolidation.all.order(:consolidation_date)
        expect(new_consolidations.count).to eq 4

        expect(new_consolidations[0].operational_risk_value).to eq 1
        expect(new_consolidations[1].operational_risk_value).to eq 1
        expect(new_consolidations[2].operational_risk_value).to eq 1
        expect(new_consolidations[3].operational_risk_value).to eq 1
      end
    end
  end
end
