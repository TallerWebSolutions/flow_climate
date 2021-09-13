# frozen_string_literal: true

RSpec.describe Highchart::FinancesChartsAdapter, type: :data_object do
  context 'having finances informations' do
    before { travel_to Time.zone.local(2018, 9, 3, 12, 20, 31) }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, company: company, customers: [customer], status: :executing, start_date: 4.months.ago, end_date: 1.week.from_now }
    let(:second_project) { Fabricate :project, company: company, customers: [customer], status: :waiting, start_date: 5.months.ago, end_date: 2.weeks.from_now }
    let(:third_project) { Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 3.months.ago, end_date: 3.weeks.from_now }

    let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 4.months.ago, end_date: 3.months.ago, effort_downstream: 16, effort_upstream: 123 }
    let!(:second_demand) { Fabricate :demand, project: second_project, commitment_date: 5.months.ago, end_date: 3.months.ago, effort_downstream: 7, effort_upstream: 221 }
    let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 3.months.ago, end_date: 2.months.ago, effort_downstream: 11, effort_upstream: 76 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, commitment_date: 2.months.ago, end_date: 1.month.ago, effort_downstream: 32, effort_upstream: 332 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, commitment_date: 2.months.ago, end_date: Time.zone.today, effort_downstream: 76, effort_upstream: 12 }

    let!(:first_finance) { Fabricate :financial_information, company: company, finances_date: 3.months.ago, expenses_total: 300, income_total: 430 }
    let!(:second_finance) { Fabricate :financial_information, company: company, finances_date: 2.months.ago, expenses_total: 200, income_total: 210 }
    let!(:third_finance) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, expenses_total: 100, income_total: 80 }

    describe '.initialize' do
      it 'computes and extracts the information of finances' do
        finances_hash = described_class.new(FinancialInformation.all).finances_hash_with_computed_informations

        expect(finances_hash[0]['income_total'].to_f).to eq 430.0
        expect(finances_hash[0]['std_dev_income'].to_f).to eq 0
        expect(finances_hash[0]['expenses_total'].to_f).to eq 300.0
        expect(finances_hash[0]['std_dev_expenses'].to_f).to eq 0
        expect(finances_hash[0]['project_delivered_hours'].to_f).to eq 367.0
        expect(finances_hash[0]['income_per_hour'].to_f).to eq 1.1716621253405994
        expect(finances_hash[0]['cost_per_hour'].to_f).to eq 0.8174386920980926
        expect(finances_hash[0]['std_dev_cost_per_hour'].to_f).to eq 0
        expect(finances_hash[0]['mean_cost_per_hour'].to_f).to eq 0.8174386920980926
        expect(finances_hash[0]['tail_events_after'].to_f).to eq 0.8174386920980926
        expect(finances_hash[0]['financial_result'].to_f).to eq 130.0
        expect(finances_hash[0]['accumulated_financial_result'].to_f.to_f).to eq 130.0
        expect(finances_hash[0]['throughput_in_month'].to_f).to eq 2

        expect(finances_hash[1]['income_total'].to_f).to eq 210.0
        expect(finances_hash[1]['std_dev_income'].to_f).to eq 155.56349186104046
        expect(finances_hash[1]['expenses_total'].to_f).to eq 200.0
        expect(finances_hash[1]['std_dev_expenses'].to_f).to eq 70.71067811865476
        expect(finances_hash[1]['project_delivered_hours'].to_f).to eq 87.0
        expect(finances_hash[1]['income_per_hour'].to_f).to eq 2.413793103448276
        expect(finances_hash[1]['cost_per_hour'].to_f).to eq 2.2988505747126435
        expect(finances_hash[1]['std_dev_cost_per_hour'].to_f).to eq 1.0475163879270788
        expect(finances_hash[1]['mean_cost_per_hour'].to_f).to eq 1.5581446334053681
        expect(finances_hash[1]['tail_events_after'].to_f).to eq 5.748210185113683
        expect(finances_hash[1]['financial_result'].to_f).to eq 10.0
        expect(finances_hash[1]['accumulated_financial_result'].to_f).to eq 140.0
        expect(finances_hash[1]['throughput_in_month']).to eq 1

        expect(finances_hash[2]['income_total'].to_f).to eq 80.0
        expect(finances_hash[2]['std_dev_income'].to_f).to eq 176.91806012954132
        expect(finances_hash[2]['expenses_total'].to_f).to eq 100.0
        expect(finances_hash[2]['std_dev_expenses'].to_f).to eq 100.0
        expect(finances_hash[2]['project_delivered_hours'].to_f).to eq 364.0
        expect(finances_hash[2]['income_per_hour'].to_f).to eq 0.21978021978021978
        expect(finances_hash[2]['cost_per_hour'].to_f).to eq 0.27472527472527475
        expect(finances_hash[2]['std_dev_cost_per_hour'].to_f).to eq 1.0477119713449419
        expect(finances_hash[2]['mean_cost_per_hour'].to_f).to eq 1.1303381805120036
        expect(finances_hash[2]['tail_events_after'].to_f).to eq 5.321186065891771
        expect(finances_hash[2]['financial_result'].to_f).to eq(-20.0)
        expect(finances_hash[2]['accumulated_financial_result'].to_f).to eq 120.0
        expect(finances_hash[2]['throughput_in_month']).to eq 1
      end
    end
  end

  context 'having no projects' do
    describe '.initialize' do
      let(:finances_hash) { described_class.new(FinancialInformation.all).finances_hash_with_computed_informations }

      it { expect(finances_hash).to be_empty }
    end
  end
end
