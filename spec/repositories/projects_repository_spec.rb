# frozen_string_literal: true

RSpec.describe ProjectsRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }

  describe '#active_projects_in_month' do
    let(:other_customer) { Fabricate :customer }

    let!(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago, end_date: 2.months.from_now, status: :executing }
    let!(:second_project) { Fabricate :project, customer: customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :maintenance }
    let!(:third_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :executing }
    let!(:fourth_project) { Fabricate :project, customer: customer, start_date: 2.months.from_now, end_date: 2.months.from_now, status: :maintenance }

    let!(:fifth_project) { Fabricate :project, customer: customer, start_date: 1.week.from_now, end_date: 1.month.from_now, status: :executing }
    let!(:sixth_project) { Fabricate :project, customer: customer, start_date: 3.months.from_now, end_date: 4.months.from_now, status: :executing }
    let!(:seventh_project) { Fabricate :project, customer: other_customer, start_date: 1.month.from_now, end_date: 3.months.from_now, status: :executing }

    it { expect(ProjectsRepository.instance.active_projects_in_month(company, 2.months.from_now)).to match_array [first_project, second_project, third_project, fourth_project] }
  end

  describe '#hours_consumed_per_month' do
    let!(:project) { Fabricate :project, customer: customer, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, start_date: 2.months.ago, end_date: 1.month.from_now }

    context 'having project results' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 30 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.day.ago, qty_hours_upstream: 0, qty_hours_downstream: 50 }
      let!(:third_result) { Fabricate :project_result, project: other_project, result_date: 2.months.ago, qty_hours_upstream: 0, qty_hours_downstream: 90 }
      let!(:out_result) { Fabricate :project_result, result_date: 1.day.ago, qty_hours_downstream: 60 }

      it { expect(ProjectsRepository.instance.hours_consumed_per_month(company, 2.months.ago.to_date)).to eq 90 }
    end

    context 'having no project results' do
      it { expect(ProjectsRepository.instance.hours_consumed_per_month(company, 2.months.ago.to_date)).to eq 0 }
    end
  end

  describe '#flow_pressure_to_month' do
    let!(:project) { Fabricate :project, customer: customer, initial_scope: 100, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, initial_scope: 50, start_date: 2.months.ago, end_date: 1.month.from_now }

    context 'having project results' do
      let!(:first_result) { Fabricate :project_result, project: project, result_date: 2.months.ago, throughput: 4, flow_pressure: 2 }
      let!(:second_result) { Fabricate :project_result, project: other_project, result_date: 1.month.ago, throughput: 10, flow_pressure: 2 }

      it { expect(ProjectsRepository.instance.flow_pressure_to_month(company, 2.months.ago.to_date)).to eq 2.0 }
    end

    context 'having no project results' do
      context 'if in the past, returns zero' do
        it { expect(ProjectsRepository.instance.flow_pressure_to_month(company, 2.months.ago.to_date)).to eq 0 }
      end
      context 'if in the future, returns the current flow pressure to the project' do
        it { expect(ProjectsRepository.instance.flow_pressure_to_month(company, 1.month.from_now.to_date)).to eq 5.357142857142858 }
      end
    end
  end

  describe '#money_to_month' do
    let!(:project) { Fabricate :project, customer: customer, value: 100, start_date: 2.months.ago, end_date: 1.month.from_now }
    let!(:other_project) { Fabricate :project, customer: customer, value: 50, start_date: 2.months.ago, end_date: 1.month.from_now }
    context 'having projects in the month' do
      it { expect(ProjectsRepository.instance.money_to_month(company, 2.months.ago.to_date).to_f).to eq 49.45054945054945 }
    end

    context 'having no projects in the month' do
      it { expect(ProjectsRepository.instance.money_to_month(company, 3.months.ago.to_date)).to eq 0 }
    end
  end
end
