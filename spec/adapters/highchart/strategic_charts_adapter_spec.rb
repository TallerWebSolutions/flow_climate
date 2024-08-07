# frozen_string_literal: true

RSpec.describe Highchart::StrategicChartsAdapter, type: :service do
  before { travel_to Time.zone.local(2018, 2, 20, 10, 0, 0) }

  describe '.active_projects_count_per_month' do
    let(:company) { Fabricate :company }
    let!(:first_financial_information) { Fabricate :financial_information, company: company, finances_date: 3.months.ago, expenses_total: 300 }
    let!(:second_financial_information) { Fabricate :financial_information, company: company, finances_date: 1.month.ago, expenses_total: 200 }
    let!(:third_financial_information) { Fabricate :financial_information, company: company, finances_date: 2.months.from_now, expenses_total: 100 }

    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, end_date: nil }
    let!(:other_team_member) { Fabricate :team_member, end_date: nil }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 20, start_date: 1.month.ago, end_date: nil }
    let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 160, start_date: 2.months.ago, end_date: 1.month.ago }

    context 'having projects' do
      let!(:first_project) { Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 3.months.ago, end_date: 2.months.ago, qty_hours: 1000, initial_scope: 95, value: 200.0 }
      let!(:second_project) { Fabricate :project, company: company, customers: [customer], status: :executing, start_date: 3.months.ago, end_date: 1.month.ago, qty_hours: 500, initial_scope: 40, value: 3_453_220.0 }
      let!(:third_project) { Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 1.month.ago, end_date: 2.months.from_now, qty_hours: 1500, initial_scope: 22, value: 10_000.0 }
      let!(:fourth_project) { Fabricate :project, company: company, customers: [customer], status: :executing, start_date: 1.month.ago, end_date: 2.months.from_now, qty_hours: 700, initial_scope: 100, value: 700.0 }
      let!(:fifth_project) { Fabricate :project, company: company, customers: [customer], status: :maintenance, start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 200, initial_scope: 42, value: 200.0 }
      let!(:sixth_project) { Fabricate :project, company: company, customers: [customer], status: :waiting, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 5000, initial_scope: 78, value: 123.0 }
      let!(:seventh_project) { Fabricate :project, company: company, customers: [customer], status: :finished, start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 8765, initial_scope: 88, value: 23.0 }
      let!(:eighth_project) { Fabricate :project, company: company, customers: [customer], status: :cancelled, start_date: 2.months.ago, end_date: 3.months.from_now, qty_hours: 1232, initial_scope: 11, value: 200.0 }

      let!(:first_demand) { Fabricate :demand, project: first_project, effort_downstream: 200, effort_upstream: 10, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, project: second_project, effort_downstream: 400, effort_upstream: 130, end_date: 1.month.ago }
      let!(:third_demand) { Fabricate :demand, project: third_project, effort_downstream: 100, effort_upstream: 20, end_date: 2.months.from_now }

      it 'mounts the data structure to the active project counts in months' do
        strategic_data = described_class.new(company, company.teams, company.projects, Demand.all, 3.months.ago, 3.months.from_now, 'month')
        expect(strategic_data.x_axis).to eq [3.months.ago.to_date.end_of_month, 2.months.ago.to_date.end_of_month, 1.month.ago.to_date.end_of_month, Time.zone.today.end_of_month, 1.month.from_now.to_date.end_of_month, 2.months.from_now.to_date.end_of_month, 3.months.from_now.to_date.end_of_month]
        expect(strategic_data.active_projects_count_data).to eq [2, 4, 3, 0, 0, 3, 4]
        expect(strategic_data.sold_hours_in_month).to eq [1175.5952380952385, 2936.367410835829, 955.1617840436312, 0.0, 0.0, 5404.566545948394, 6686.36741083583]
        expect(strategic_data.consumed_hours_per_month).to eq [0.0, 210.0, 530.0, 0.0, 0.0, 120.0, 0.0]
        expect(strategic_data.available_hours_per_period).to eq [0.0, 63.99999999999999, 114.66666666666666, 18.666666666666664]
        expect(strategic_data.flow_pressure_per_month_data.map { |pressure| pressure.round(2) }).to eq [0.0, 1.57, 2.03, 0.0, 0.0, 4.55, 4.08]
        expect(strategic_data.money_per_month_data.map { |money| money.round(2) }).to eq [1_644_577.98, 270.42, 1_647_878.03, 0.0, 0.0, 3602.86, 198.23]
        expect(strategic_data.expenses_per_month_data.map { |expense| expense.round(2) }).to eq [300.0, 300.0, 200.0, 200.0, 200.0, 100.0, 100.0]
      end
    end

    context 'having no projects' do
      it 'returns an empty array' do
        strategic_data = described_class.new(company, company.teams, company.projects, Demand.all, 2.months.ago, 1.day.ago, 'month')
        expect(strategic_data.x_axis).to eq []
        expect(strategic_data.active_projects_count_data).to eq []
      end
    end
  end
end
