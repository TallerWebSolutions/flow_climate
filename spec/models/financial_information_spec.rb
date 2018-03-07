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
    pending '.for_month'
  end

  describe '#financial_result' do
    let(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    it { expect(finances.financial_result).to eq 8.2 }
  end

  describe '#cost_per_hour' do
    let(:company) { Fabricate :company }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
    let!(:result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 30 }
    let!(:other_result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 50 }
    let!(:out_result) { Fabricate :operation_result, result_date: 1.month.ago, delivered_hours: 60 }

    it { expect(finances.cost_per_hour).to eq finances.expenses_total / 80 }
  end

  describe '#hours_delivered_projects' do
    let!(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    let(:customer) { Fabricate :customer, company: finances.company }
    let(:product) { Fabricate :product, customer: customer, name: 'zzz' }
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:result) { Fabricate :project_result, project: project, result_date: finances.finances_date, qty_hours_upstream: 0, qty_hours_downstream: 30 }
    let!(:other_result) { Fabricate :project_result, project: other_project, result_date: finances.finances_date, qty_hours_upstream: 0, qty_hours_downstream: 50 }
    let!(:out_result) { Fabricate :project_result, result_date: finances.finances_date, qty_hours_upstream: 0, qty_hours_downstream: 60 }

    it { expect(finances.project_delivered_hours).to eq 80 }
  end

  describe '#hours_delivered_operation_result' do
    let(:company) { Fabricate :company }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
    let!(:result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 30 }
    let!(:other_result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 50 }
    let!(:out_result) { Fabricate :operation_result, result_date: 1.month.ago, delivered_hours: 60 }

    it { expect(finances.hours_delivered_operation_result).to eq 80 }
  end

  describe '#throughput_operation_result' do
    let(:company) { Fabricate :company }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
    let!(:result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 30, total_th: 10 }
    let!(:other_result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 50, total_th: 5 }
    let!(:out_result) { Fabricate :operation_result, result_date: 1.month.ago, delivered_hours: 60, total_th: 1 }

    it { expect(finances.throughput_operation_result).to eq 15 }
  end

  describe '#hours_per_demand' do
    let(:company) { Fabricate :company }
    let!(:finances) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, income_total: 20.4, expenses_total: 12.2 }
    let!(:result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 30, total_th: 10 }
    let!(:other_result) { Fabricate :operation_result, company: company, result_date: 1.month.ago, delivered_hours: 50, total_th: 5 }
    let!(:out_result) { Fabricate :operation_result, result_date: 1.month.ago, delivered_hours: 60, total_th: 1 }

    it { expect(finances.hours_per_demand).to be_within(0.01).of(5.3333) }
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
