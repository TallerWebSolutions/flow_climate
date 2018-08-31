# frozen_string_literal: true

RSpec.describe FinancialInformation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :finances_date }
    it { is_expected.to validate_presence_of :income_total }
    it { is_expected.to validate_presence_of :expenses_total }
  end

  context 'scopes' do
    before { travel_to Date.new(2018, 8, 31) }
    after { travel_back }
    pending '.for_month'
    describe '.for_year' do
      let!(:first_finances) { Fabricate :financial_information, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
      let!(:second_finances) { Fabricate :financial_information, finances_date: Time.zone.today, income_total: 20.4, expenses_total: 12.2 }
      let!(:third_finances) { Fabricate :financial_information, finances_date: 1.year.ago, income_total: 20.4, expenses_total: 12.2 }

      it { expect(FinancialInformation.for_year(2018)).to match_array [first_finances, second_finances] }
    end
  end

  describe '#financial_result' do
    let(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    it { expect(finances.financial_result).to eq 8.2 }
  end

  describe '#cost_per_hour' do
    let(:company) { Fabricate :company }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customer: customer }
    let!(:project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_downstream: 20, qty_hours_upstream: 10 }
    let!(:other_project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_downstream: 30, qty_hours_upstream: 20 }
    let!(:out_project_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, qty_hours_downstream: 130, qty_hours_upstream: 202 }

    it { expect(finances.cost_per_hour.to_f).to eq finances.expenses_total / 80 }
  end

  describe '#income_per_hour' do
    let(:company) { Fabricate :company }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customer: customer }
    let!(:project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_downstream: 20, qty_hours_upstream: 10 }
    let!(:other_project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, qty_hours_downstream: 30, qty_hours_upstream: 20 }
    let!(:out_project_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, qty_hours_downstream: 130, qty_hours_upstream: 202 }

    it { expect(finances.income_per_hour.to_f).to eq finances.income_total / 80 }
  end

  describe '#project_delivered_hours' do
    let!(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    let(:customer) { Fabricate :customer, company: finances.company }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let!(:project) { Fabricate :project, customer: customer, product: product, start_date: 4.weeks.ago, end_date: 3.weeks.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, product: product, start_date: 4.weeks.ago, end_date: 3.weeks.from_now }
    let!(:out_project) { Fabricate :project, start_date: 4.weeks.ago, end_date: 3.weeks.from_now }
    let!(:result) { Fabricate :project_result, project: project, result_date: finances.finances_date, qty_hours_upstream: 0, qty_hours_downstream: 30 }
    let!(:other_result) { Fabricate :project_result, project: other_project, result_date: finances.finances_date, qty_hours_upstream: 0, qty_hours_downstream: 50 }
    let!(:out_result) { Fabricate :project_result, project: out_project, result_date: finances.finances_date, qty_hours_upstream: 0, qty_hours_downstream: 60 }

    it { expect(finances.project_delivered_hours).to eq 80 }
  end

  describe '#throughput_in_month' do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customer: customer }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    let!(:project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput_downstream: 20, throughput_upstream: 10 }
    let!(:other_project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput_downstream: 30, throughput_upstream: 20 }
    let!(:out_project_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, throughput_downstream: 130, throughput_upstream: 202 }

    it { expect(finances.throughput_in_month).to eq 80 }
  end

  describe '#hours_per_demand' do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customer: customer }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }

    let!(:project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput_downstream: 20, throughput_upstream: 10, qty_hours_downstream: 50, qty_hours_upstream: 70 }
    let!(:other_project_result) { Fabricate :project_result, project: project, result_date: 1.month.ago, throughput_downstream: 30, throughput_upstream: 20, qty_hours_downstream: 10, qty_hours_upstream: 30 }
    let!(:out_project_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, throughput_downstream: 130, throughput_upstream: 202, qty_hours_downstream: 22, qty_hours_upstream: 56 }

    it { expect(finances.hours_per_demand).to eq 2 }
  end

  describe '#red?' do
    let(:company) { Fabricate :company }
    context 'when the expenses are greather than incomes' do
      let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 30 }
      it { expect(finances.red?).to be true }
    end
    context 'when the expenses are smaller than incomes' do
      let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 1 }
      it { expect(finances.red?).to be false }
    end
  end
end
