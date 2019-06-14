# frozen_string_literal: true

RSpec.describe TeamService, type: :service do
  before { travel_to Time.zone.local(2018, 6, 20, 10, 0, 0) }

  after { travel_back }

  describe '#compute_average_demand_cost_to_team' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }
    let!(:other_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 10_000, start_date: 2.months.ago, end_date: 1.month.ago }

    let(:customer) { Fabricate :customer, company: company }

    context 'with data' do
      let!(:product) { Fabricate :product, customer: customer }
      let(:first_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }
      let(:second_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.now }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, end_date: Time.zone.now }

      it 'returns the average demand cost to the selected period' do
        expect(TeamService.instance.compute_average_demand_cost_to_team(team, 1.month.ago.to_date, Time.zone.today, 'month')).to eq(Date.new(2018, 5, 31) => 2500.0, Date.new(2018, 6, 30) => 5000.0)
      end
    end

    context 'without data' do
      it 'returns an empty hash' do
        expect(TeamService.instance.compute_average_demand_cost_to_team(team, 1.month.ago.to_date, Time.zone.today, 'month')).to eq(Date.new(2018, 5, 31) => 10_000.0, Date.new(2018, 6, 30) => 10_000.0)
      end
    end
  end
end
