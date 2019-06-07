# frozen_string_literal: true

RSpec.describe ProjectFinancesService, type: :service do
  before { travel_to Time.zone.local(2018, 6, 20, 10, 0, 0) }

  after { travel_back }

  describe '#effort_share_in_month' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, active: true, billable_type: :outsourcing, billable: true, team: team, monthly_payment: 100 }

    let(:customer) { Fabricate :customer, company: company }

    context 'when the projects have a team' do
      let!(:product) { Fabricate :product, customer: customer, team: team }
      let(:first_project) { Fabricate :project, company: company, product: product, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }
      let(:second_project) { Fabricate :project, company: company, product: product, customers: [customer], project_type: :outsourcing, start_date: 1.month.ago, end_date: Time.zone.tomorrow }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago, effort_downstream: 100, effort_upstream: 50 }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 1.month.ago, effort_downstream: 200, effort_upstream: 230 }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.now, effort_downstream: 50, effort_upstream: 70 }

      let!(:fourth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago, effort_downstream: 110, effort_upstream: 100 }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.month.ago, effort_downstream: 220, effort_upstream: 235 }
      let!(:sixth_demand) { Fabricate :demand, project: second_project, end_date: Time.zone.now, effort_downstream: 140, effort_upstream: 148 }

      it 'returns the share of used hours in the project in the month' do
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, 1.month.ago)).to eq 0.46586345381526106
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, Time.zone.now)).to eq 0.29411764705882354

        expect(ProjectFinancesService.instance.effort_share_in_month(second_project, 1.month.ago)).to eq 0.5341365461847389
        expect(ProjectFinancesService.instance.effort_share_in_month(second_project, Time.zone.now)).to eq 0.7058823529411765
      end
    end

    context 'when the projects have no team' do
      let(:first_project) { Fabricate :project, project_type: :outsourcing, start_date: 1.month.ago }

      it 'returns 0 to the share of the used effort' do
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, 1.month.ago)).to eq 0
        expect(ProjectFinancesService.instance.effort_share_in_month(first_project, Time.zone.now)).to eq 0
      end
    end
  end
end
