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

  describe '#financial_result' do
    let(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    it { expect(finances.financial_result).to eq 8.2 }
  end

  describe '#hours_delivered' do
    let!(:finances) { Fabricate :financial_information, income_total: 20.4, expenses_total: 12.2 }
    let(:customer) { Fabricate :customer, company: finances.company }
    let!(:project) { Fabricate :project, customer: customer }
    let!(:other_project) { Fabricate :project, customer: customer }
    let!(:result) { Fabricate :project_result, project: project, result_date: finances.finances_date, qty_hours_downstream: 30 }
    let!(:other_result) { Fabricate :project_result, project: other_project, result_date: finances.finances_date, qty_hours_downstream: 50 }
    let!(:out_result) { Fabricate :project_result, result_date: finances.finances_date, qty_hours_downstream: 60 }

    it { expect(finances.hours_delivered).to eq 80 }
  end
end
