# frozen_string_literal: true

RSpec.describe ProjectResultsRepository, type: :repository do
  describe '#project_results_for_company_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let!(:project) { Fabricate :project, customer: customer }
    let!(:other_project) { Fabricate :project, customer: customer }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_downstream: 80 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.project_results_for_company_month(company, 1.day.ago.month, 1.day.ago.year)).to match_array [first_result, second_result] }
  end
end
