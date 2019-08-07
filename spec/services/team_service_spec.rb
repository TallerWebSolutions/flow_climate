# frozen_string_literal: true

RSpec.describe TeamService, type: :service do
  before { travel_to Time.zone.local(2018, 6, 20, 10, 0, 0) }

  after { travel_back }

  describe '#compute_average_demand_cost_to_team' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }
    let!(:first_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, teams: [team], monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }
    let!(:second_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, teams: [team], monthly_payment: 10_000, start_date: 2.months.ago, end_date: 1.month.ago }
    let!(:third_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: false, teams: [team], monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }

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
        expect(described_class.instance.compute_average_demand_cost_to_team(team, 1.month.ago.to_date, Time.zone.today, 'month')).to eq(Date.new(2018, 5, 31) => 2500.0, Date.new(2018, 6, 30) => 5000.0)
      end
    end

    context 'without data' do
      it 'returns an empty hash' do
        expect(described_class.instance.compute_average_demand_cost_to_team(team, 1.month.ago.to_date, Time.zone.today, 'month')).to eq(Date.new(2018, 5, 31) => 10_000.0, Date.new(2018, 6, 30) => 10_000.0)
      end
    end
  end

  describe '#compute_average_demand_cost_to_team' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }

    context 'with data' do
      let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, teams: [team], monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }
      let!(:other_team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, teams: [team], monthly_payment: 10_000, start_date: 2.months.ago, end_date: 1.month.ago }

      let(:customer) { Fabricate :customer, company: company }

      let!(:product) { Fabricate :product, customer: customer }
      let(:first_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }
      let(:second_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.now }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, end_date: 2.weeks.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: nil }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, end_date: nil }

      it 'returns the average demand cost informations in a hash' do
        expect(described_class.instance.average_demand_cost_info_hash(team)).to eq(cmd_difference_to_avg_last_four_weeks: 14.285714285714285, current_week: 2500.0, four_weeks_cmd_average: 2187.5, last_week: 1250.0, team_name: team.name)
      end
    end

    context 'without data' do
      it { expect(described_class.instance.average_demand_cost_info_hash(team)).to eq(cmd_difference_to_avg_last_four_weeks: 0, current_week: 0, four_weeks_cmd_average: 0, last_week: 0, team_name: team.name) }
    end
  end
end
