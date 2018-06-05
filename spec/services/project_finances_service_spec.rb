# frozen_string_literal: true

RSpec.describe ProjectFinancesService, type: :service do
  describe '#compute_cost_for_average_demand_cost' do
    before { travel_to Time.zone.local(2018, 6, 4, 10, 0, 0) }
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100, hours_per_month: 22, total_monthly_payment: 10_000 }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }

    context 'when the projects have a team' do
      let(:first_project) { Fabricate :project, product: product, customer: customer, project_type: :outsourcing }
      let(:second_project) { Fabricate :project, product: product, customer: customer, project_type: :outsourcing }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago, effort_downstream: 100, effort_upstream: 50 }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago, effort_downstream: 200, effort_upstream: 230 }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.now, effort_downstream: 50, effort_upstream: 70 }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago, effort_downstream: 110, effort_upstream: 100 }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago, effort_downstream: 220, effort_upstream: 235 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, end_date: Time.zone.now, effort_downstream: 140, effort_upstream: 148 }

      it 'computes the correct money ammount' do
        expect(ProjectFinancesService.instance.compute_cost_for_average_demand_cost(first_project, Date.new(2018, 5, 1))).to eq 4658.634538152611
        expect(ProjectFinancesService.instance.compute_cost_for_average_demand_cost(first_project, Date.new(2018, 6, 1))).to eq 2941.1764705882356

        expect(ProjectFinancesService.instance.compute_cost_for_average_demand_cost(second_project, Date.new(2018, 5, 1))).to eq 5341.365461847389
        expect(ProjectFinancesService.instance.compute_cost_for_average_demand_cost(second_project, Date.new(2018, 6, 1))).to eq 7058.823529411765
      end
    end

    context 'when the projects have no team' do
      let(:first_project) { Fabricate :project }

      it 'returns 0 to the used cost' do
        expect(ProjectFinancesService.instance.compute_cost_for_average_demand_cost(first_project, Date.new(2018, 5, 1))).to eq 0
        expect(ProjectFinancesService.instance.compute_cost_for_average_demand_cost(first_project, Date.new(2018, 6, 1))).to eq 0
      end
    end
  end

  describe '#effort_share_in_month' do
    before { travel_to Time.zone.local(2018, 6, 4, 10, 0, 0) }
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100, hours_per_month: 22, total_monthly_payment: 10_000 }

    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer, team: team }

    context 'when the projects have a team' do
      let(:first_project) { Fabricate :project, product: product, customer: customer, project_type: :outsourcing }
      let(:second_project) { Fabricate :project, product: product, customer: customer, project_type: :outsourcing }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago, effort_downstream: 100, effort_upstream: 50 }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago, effort_downstream: 200, effort_upstream: 230 }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.now, effort_downstream: 50, effort_upstream: 70 }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago, effort_downstream: 110, effort_upstream: 100 }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago, effort_downstream: 220, effort_upstream: 235 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, end_date: Time.zone.now, effort_downstream: 140, effort_upstream: 148 }

      it 'returns the share of used hours in the project in the month' do
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, Date.new(2018, 5, 1))).to eq 0.46586345381526106
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, Date.new(2018, 6, 1))).to eq 0.29411764705882354

        expect(ProjectFinancesService.instance.effort_share_in_month(second_project, Date.new(2018, 5, 1))).to eq 0.5341365461847389
        expect(ProjectFinancesService.instance.effort_share_in_month(second_project, Date.new(2018, 6, 1))).to eq 0.7058823529411765
      end
    end

    context 'when the projects have no team' do
      let(:first_project) { Fabricate :project }

      it 'returns 0 to the share of the used effort' do
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, Date.new(2018, 5, 1))).to eq 0
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, Date.new(2018, 6, 1))).to eq 0
      end
    end
  end
end
