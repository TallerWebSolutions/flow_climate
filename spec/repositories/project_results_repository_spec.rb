# frozen_string_literal: true

RSpec.describe ProjectResultsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer, name: 'zzz' }

  describe '#project_results_for_company_month' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_downstream: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.project_results_for_company_month(company, 1.day.ago.month, 1.day.ago.year)).to match_array [first_result, second_result] }
  end

  describe '#consumed_hours_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_upstream: 0, qty_hours_downstream: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

    it { expect(ProjectResultsRepository.instance.consumed_hours_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#th_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, throughput: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, throughput: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 60 }

    it { expect(ProjectResultsRepository.instance.th_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#th_in_week_for_project' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, throughput: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, throughput: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, throughput: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, throughput: 60 }

    it { expect(ProjectResultsRepository.instance.th_in_week_for_projects([project], 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 30 }
  end

  describe '#bugs_opened_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_bugs_opened: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_bugs_opened: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_bugs_opened: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_opened: 60 }

    it { expect(ProjectResultsRepository.instance.bugs_opened_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#bugs_closed_in_week' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_bugs_closed: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_bugs_closed: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_bugs_closed: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60 }

    it { expect(ProjectResultsRepository.instance.bugs_closed_in_week(company, 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq 80 }
  end

  describe '#scope_in_week_for_project' do
    let!(:project) { Fabricate :project, customer: customer, product: product }
    let!(:other_project) { Fabricate :project, customer: customer, product: product }
    let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_bugs_closed: 30 }
    let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 2.days.ago, qty_bugs_closed: 50 }
    let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_bugs_closed: 90 }
    let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_bugs_closed: 60 }

    it { expect(ProjectResultsRepository.instance.scope_in_week_for_projects([project], 1.day.ago.to_date.cweek, 1.day.ago.to_date.cwyear)).to eq first_result.known_scope }
  end
end
