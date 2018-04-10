# frozen_string_literal: true

RSpec.describe StrategicReportData, type: :service do
  before { travel_to Time.zone.local(2018, 2, 20, 10, 0, 0) }
  after { travel_back }

  describe '.active_projects_count_per_month' do
    let(:company) { Fabricate :company }
    let!(:first_financial_information) { Fabricate :financial_information, company: company, finances_date: 3.months.ago, expenses_total: 300 }
    let!(:second_financial_information) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, expenses_total: 200 }
    let!(:third_financial_information) { Fabricate :financial_information, company: company, finances_date: 2.months.from_now, expenses_total: 100 }

    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 20 }
    let!(:other_team_member) { Fabricate :team_member, team: team, hours_per_month: 160 }

    context 'having projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 3.months.ago, end_date: 2.months.ago, qty_hours: 1000, initial_scope: 95, value: 200.0 }
      let!(:second_project) { Fabricate :project, customer: customer, status: :executing, start_date: 3.months.ago, end_date: 2.months.ago, qty_hours: 500, initial_scope: 40, value: 3_453_220.0 }
      let!(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 1.month.from_now, end_date: 2.months.from_now, qty_hours: 1500, initial_scope: 22, value: 10_000.0 }
      let!(:fourth_project) { Fabricate :project, customer: customer, status: :executing, start_date: 1.month.from_now, end_date: 2.months.from_now, qty_hours: 700, initial_scope: 100, value: 700.0 }
      let!(:fifth_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 200, initial_scope: 42, value: 200.0 }
      let!(:sixth_project) { Fabricate :project, customer: customer, status: :waiting, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 5000, initial_scope: 78, value: 123.0 }
      let!(:seventh_project) { Fabricate :project, customer: customer, status: :finished, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 8765, initial_scope: 88, value: 23.0 }
      let!(:eighth_project) { Fabricate :project, customer: customer, status: :cancelled, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 1232, initial_scope: 11, value: 200.0 }

      let!(:first_project_result) { Fabricate :project_result, project: first_project, team: team, result_date: 3.months.ago, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 20, throughput_downstream: 10, flow_pressure: 6 }
      let!(:second_project_result) { Fabricate :project_result, project: second_project, team: team, result_date: 3.months.ago, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 3, throughput_downstream: 1, flow_pressure: 2 }
      let!(:third_project_result) { Fabricate :project_result, project: third_project, team: team, result_date: 1.month.from_now, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 11, throughput_downstream: 12, flow_pressure: 0.8 }
      let!(:fourth_project_result) { Fabricate :project_result, project: fourth_project, team: team, result_date: 1.month.from_now, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 25, throughput_downstream: 31, flow_pressure: 0.3 }
      let!(:fifth_project_result) { Fabricate :project_result, project: fifth_project, team: team, result_date: 2.months.from_now, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 2, throughput_downstream: 13, flow_pressure: 1 }
      let!(:sixth_project_result) { Fabricate :project_result, project: sixth_project, team: team, result_date: 2.months.from_now, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 44, throughput_downstream: 16, flow_pressure: 0.78 }
      let!(:seventh_project_result) { Fabricate :project_result, project: seventh_project, team: team, result_date: 2.months.from_now, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 12, throughput_downstream: 11, flow_pressure: 0.4 }
      let!(:eighth_project_result) { Fabricate :project_result, project: eighth_project, team: team, result_date: 2.months.from_now, qty_hours_upstream: 10, qty_hours_downstream: 40, available_hours: 234, throughput_upstream: 5, throughput_downstream: 18, flow_pressure: 1 }

      it 'mounts the data structure to the active project counts in months' do
        strategic_data = StrategicReportData.new(company, company.projects, company.total_available_hours)
        expect(strategic_data.array_of_months).to eq [[3.months.ago.to_date.month, 3.months.ago.to_date.year], [2.months.ago.to_date.month, 2.months.ago.to_date.year], [1.month.ago.to_date.month, 1.month.ago.to_date.year], [Time.zone.today.month, Time.zone.today.year], [1.month.from_now.to_date.month, 1.month.from_now.to_date.year], [2.months.from_now.to_date.month, 2.months.from_now.to_date.year], [3.months.from_now.to_date.month, 3.months.from_now.to_date.year]]
        expect(strategic_data.active_projects_count_data).to eq [2, 2, 0, 0, 2, 4, 2]
        expect(strategic_data.sold_hours_in_month).to eq [1451.6129032258063, 1451.6129032258063, 0, 0, 2062.5, 7094.758064516129, 5032.258064516129]
        expect(strategic_data.consumed_hours_per_month).to eq [100, 0, 0, 0, 100, 100, 0]
        expect(strategic_data.available_hours_per_month).to eq [180, 180, 180, 180, 180, 180, 180]
        expect(strategic_data.flow_pressure_per_month_data.map { |pressure| pressure.round(2) }).to eq [8.0, 0.0, 0.0, 0.0, 1.1, 5.59, 3.87]
        expect(strategic_data.money_per_month_data.map { |money| money.round(2) }).to eq [3_342_019.35, 3_342_019.35, 0.0, 0.0, 10_031.25, 10_343.83, 312.58]
        expect(strategic_data.expenses_per_month_data.map { |expense| expense.round(2) }).to eq [300.0, 300.0, 200.0, 200.0, 200.0, 100.0, 100.0]
      end
    end

    context 'having no projects' do
      it 'returns an empty array' do
        strategic_data = StrategicReportData.new(company, company.projects, company.total_available_hours)
        expect(strategic_data.array_of_months).to eq []
        expect(strategic_data.active_projects_count_data).to eq []
      end
    end
  end
end
