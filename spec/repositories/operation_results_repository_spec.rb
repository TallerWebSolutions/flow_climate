# frozen_string_literal: true

RSpec.describe ProjectResultsRepository, type: :repository do
  describe '#project_results_for_company_month' do
    let(:company) { Fabricate :company }
    let!(:first_result) { Fabricate :operation_result, company: company, result_date: 1.month.ago }
    let!(:second_result) { Fabricate :operation_result, company: company, result_date: Time.zone.today }
    let!(:out_result) { Fabricate :operation_result, result_date: 1.day.ago }

    it { expect(OperationResultsRepository.instance.operation_results_for_company_month(company, 1.month.ago.month, 1.month.ago.year)).to eq [first_result] }
  end
end
