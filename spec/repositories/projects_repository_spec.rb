# frozen_string_literal: true

RSpec.describe ProjectsRepository, type: :repository do
  describe '#running_projects_in_month' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:other_customer) { Fabricate :customer }

    let!(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
    let!(:second_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
    let!(:third_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :executing }
    let!(:fourth_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }

    let!(:fifth_project) { Fabricate :project, customer: customer, start_date: 1.week.from_now, end_date: 1.month.from_now, status: :executing }
    let!(:sixth_project) { Fabricate :project, customer: customer, start_date: 3.months.from_now, end_date: 4.months.from_now, status: :executing }
    let!(:seventh_project) { Fabricate :project, customer: other_customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }

    it { expect(ProjectsRepository.instance.running_projects_in_month(company, 2.months.from_now)).to match_array [first_project, second_project, third_project, fourth_project] }
  end
end
