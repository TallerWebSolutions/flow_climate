# frozen_string_literal: true

RSpec.describe TeamService, type: :service do
  before { travel_to Time.zone.local(2018, 6, 20, 10, 0, 0) }

  describe '#compute_average_demand_cost_to_team' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }

    let!(:first_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }
    let!(:second_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 2.months.ago, end_date: 1.month.ago }
    let!(:third_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }

    let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, start_date: 1.month.ago, end_date: nil, member_role: :developer, hours_per_month: 120 }
    let!(:second_membership) { Fabricate :membership, team: team, team_member: second_team_member, start_date: 2.months.ago, end_date: 1.month.ago, member_role: :developer, hours_per_month: 40 }
    let!(:third_membership) { Fabricate :membership, team: team, team_member: third_team_member, start_date: 1.month.ago, end_date: nil, member_role: :client, hours_per_month: 120 }

    let!(:first_team_resource) { Fabricate :team_resource, company: company }
    let!(:second_team_resource) { Fabricate :team_resource, company: company }

    let!(:first_allocation) { Fabricate :team_resource_allocation, team: team, team_resource: first_team_resource, start_date: 1.month.ago, end_date: nil, monthly_payment: 2000 }
    let!(:second_allocation) { Fabricate :team_resource_allocation, team: team, team_resource: second_team_resource, start_date: 1.month.ago, end_date: nil, monthly_payment: 25_000 }

    let(:customer) { Fabricate :customer, company: company }

    context 'with data' do
      let!(:product) { Fabricate :product, company: company, customer: customer }
      let(:first_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }
      let(:second_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }

      let!(:first_demand) { Fabricate :demand, project: first_project, team: team, end_date: 1.month.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, team: team, end_date: 1.month.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, team: team, end_date: Time.zone.now }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, team: team, end_date: 1.month.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, team: team, end_date: 1.month.ago }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, team: team, end_date: Time.zone.now }

      it 'returns the average demand cost to the selected period' do
        expect(described_class.instance.compute_average_demand_cost_to_team(team, 1.month.ago.to_date, Time.zone.today, 'month')).to eq(Date.new(2018, 5, 31) => 11_750.0, Date.new(2018, 6, 30) => 23_500.0)
      end
    end

    context 'without data' do
      it 'returns an empty hash' do
        expect(described_class.instance.compute_average_demand_cost_to_team(team, 1.month.ago.to_date, Time.zone.today, 'month')).to eq(Date.new(2018, 5, 31) => 47_000, Date.new(2018, 6, 30) => 47_000)
      end
    end
  end

  describe '#average_demand_cost_stats_info_hash' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }

    context 'with data' do
      let!(:team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }
      let!(:other_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 2.months.ago, end_date: 1.month.ago }
      let!(:null_payment_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: nil, start_date: 2.months.ago, end_date: nil }

      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
      let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
      let!(:null_payment_membership) { Fabricate :membership, team: team, team_member: null_payment_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

      let(:customer) { Fabricate :customer, company: company }

      let!(:product) { Fabricate :product, company: company, customer: customer }
      let(:first_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }
      let(:second_project) { Fabricate :project, company: company, team: team, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }

      let!(:first_demand) { Fabricate :demand, project: first_project, team: team, end_date: 1.week.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, team: team, end_date: 1.week.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, team: team, end_date: Time.zone.now }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, team: team, end_date: 2.weeks.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, team: team, end_date: nil }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, team: team, end_date: nil }

      it 'returns the average demand cost informations in a hash' do
        expect(described_class.instance.average_demand_cost_stats_info_hash(team)).to eq(cmd_difference_to_avg_last_four_weeks: 14.285714285714285, current_week: 2500.0, four_weeks_cmd_average: 2187.5, last_week: 1250.0, team_name: team.name)
      end
    end

    context 'without data' do
      it { expect(described_class.instance.average_demand_cost_stats_info_hash(team)).to eq(cmd_difference_to_avg_last_four_weeks: 0, current_week: 0, four_weeks_cmd_average: 0, last_week: 0, team_name: team.name) }
    end

    describe '#compute_available_hours_to_team' do
      let(:company) { Fabricate :company }
      let!(:team) { Fabricate :team, company: company }

      context 'with data' do
        let!(:team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 1.month.ago, end_date: nil }
        let!(:other_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: 10_000, start_date: 2.months.ago, end_date: 1.month.ago }
        let!(:null_payment_team_member) { Fabricate :team_member, billable_type: :outsourcing, billable: true, monthly_payment: nil, start_date: 2.months.ago, end_date: nil }

        let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
        let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
        let!(:null_payment_membership) { Fabricate :membership, team: team, team_member: null_payment_team_member, hours_per_month: 120, start_date: 2.months.ago, end_date: nil }

        it 'returns the average demand cost informations in a hash' do
          expect(described_class.instance.compute_available_hours_to_team([team], 3.months.ago.to_date, Time.zone.today, :monthly)).to eq(Date.new(2018, 3, 31) => 0.0, Date.new(2018, 4, 30) => 58.666666666666664, Date.new(2018, 5, 31) => 198.66666666666666, Date.new(2018, 6, 30) => 240.0)
        end
      end

      context 'without data' do
        it { expect(described_class.instance.compute_available_hours_to_team([team], 3.months.ago.to_date, Time.zone.today, :monthly)).to eq(Date.new(2018, 3, 31) => 0.0, Date.new(2018, 4, 30) => 0.0, Date.new(2018, 5, 31) => 0.0, Date.new(2018, 6, 30) => 0.0) }
      end
    end
  end
end
