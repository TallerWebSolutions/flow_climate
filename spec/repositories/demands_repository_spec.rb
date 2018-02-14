# frozen_string_literal: true

RSpec.describe DemandsRepository, type: :repository do
  describe '#demands_for_company_and_week' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:second_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:third_project) { Fabricate :project, customer: customer, end_date: 1.week.from_now }
    let(:fourth_project) { Fabricate :project, customer: customer, end_date: 1.week.from_now }

    let(:first_project_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago }
    let(:second_project_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago }
    let(:third_project_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today }

    let!(:first_demand) { Fabricate :demand, project_result: first_project_result, demand_id: 'zzz' }
    let!(:second_demand) { Fabricate :demand, project_result: first_project_result, demand_id: 'aaa' }
    let!(:third_demand) { Fabricate :demand, project_result: second_project_result, demand_id: 'sss' }
    let!(:fourth_demand) { Fabricate :demand, project_result: third_project_result }

    it { expect(DemandsRepository.instance.demands_for_company_and_week(company, 1.week.ago.to_date)).to eq [second_demand, third_demand, first_demand] }
  end

  describe '#update_demand_and_project_result' do
    let(:created_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
    let(:commitment_date) { Time.zone.local(2018, 2, 15, 16, 0, 0) }
    let(:end_date) { Time.zone.local(2018, 2, 17, 16, 0, 0) }

    let(:project) { Fabricate :project }
    let!(:project_result) { Fabricate :project_result, project: project, result_date: end_date }
    let!(:demand) { Fabricate :demand, project_result: project_result }

    it 'updates the demand and the project result' do
      expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, end_date, 40, 0).once
      DemandsRepository.instance.update_demand_and_project_result(demand, 30, :bug, created_date, commitment_date, end_date, 40, project, project_result)

      updated_demand = Demand.last
      expect(updated_demand.effort).to eq 30
      expect(updated_demand.demand_type).to eq 'bug'
      expect(updated_demand.created_date).to eq created_date
      expect(updated_demand.commitment_date).to eq commitment_date
      expect(updated_demand.end_date).to eq end_date
    end
  end

  describe '#create_or_update_demand' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100, hours_per_month: 30 }
    let!(:project) { Fabricate :project }

    context 'when the demand does not exist' do
      it 'creates the demand and the project result' do
        created_date = 2.days.ago.change(usec: 0).change(sec: 0)
        commitment_date = 1.day.ago.change(usec: 0).change(sec: 0)
        end_date = Time.zone.now.change(usec: 0).change(sec: 0)
        DemandsRepository.instance.create_or_update_demand(project, team, '100', 'bug', commitment_date, created_date, end_date)

        updated_demand = Demand.last
        expect(updated_demand.demand_id).to eq '100'
        expect(updated_demand.demand_type).to eq 'bug'
        expect(updated_demand.effort.to_f).to eq 16.0
        expect(updated_demand.created_date).to eq created_date
        expect(updated_demand.commitment_date).to eq commitment_date
        expect(updated_demand.end_date).to eq end_date

        updated_project_result = ProjectResult.last
        expect(updated_project_result.demands).to match_array [updated_demand]
        expect(updated_project_result.project).to eq project
        expect(updated_project_result.team).to eq team
        expect(updated_project_result.result_date).to eq end_date.to_date
        expect(updated_project_result.known_scope).to eq 1
        expect(updated_project_result.throughput).to eq 1
        expect(updated_project_result.qty_hours_upstream).to eq 0
        expect(updated_project_result.qty_hours_downstream).to eq 16
        expect(updated_project_result.qty_hours_bug).to eq 16.0
        expect(updated_project_result.qty_bugs_closed).to eq 1
        expect(updated_project_result.qty_bugs_opened).to eq 0
        expect(updated_project_result.flow_pressure.to_f).to eq 0.0169491525423729
        expect(updated_project_result.remaining_days).to eq 59
        expect(updated_project_result.cost_in_week.to_f).to eq 25.0
        expect(updated_project_result.average_demand_cost.to_f).to eq 25.0
        expect(updated_project_result.available_hours.to_f).to eq 30
      end
    end
    context 'when the demand exist' do
      let(:created_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
      let(:commitment_date) { Time.zone.local(2018, 2, 15, 16, 0, 0) }
      let(:end_date) { Time.zone.local(2018, 2, 17, 16, 0, 0) }

      let(:project) { Fabricate :project }
      let!(:project_result) { Fabricate :project_result, team: team, project: project, result_date: created_date, throughput: 1, known_scope: 1, qty_hours_upstream: 0, qty_hours_downstream: 50, cost_in_week: 200, available_hours: 30 }
      let!(:demand) { Fabricate :demand, project_result: project_result, demand_id: '100', effort: 25, created_date: created_date }

      it 'updates the demand and the project result' do
        DemandsRepository.instance.create_or_update_demand(project, team, '100', 'bug', commitment_date, created_date, end_date)
        expect(ProjectResult.count).to eq 2
        updated_project_result = ProjectResult.order(:result_date).first
        created_project_result = ProjectResult.order(:result_date).second

        updated_demand = Demand.last
        expect(updated_demand.demand_id).to eq '100'
        expect(updated_demand.demand_type).to eq 'bug'
        expect(updated_demand.created_date).to eq created_date
        expect(updated_demand.commitment_date).to eq commitment_date
        expect(updated_demand.end_date).to eq end_date
        expect(updated_demand.project_result).to eq created_project_result

        expect(updated_project_result.demands).to eq []
        expect(updated_project_result.project).to eq project
        expect(updated_project_result.team).to eq team
        expect(updated_project_result.result_date).to eq created_date.to_date
        expect(updated_project_result.known_scope).to eq 1
        expect(updated_project_result.throughput).to eq 0
        expect(updated_project_result.qty_hours_upstream).to eq 0
        expect(updated_project_result.qty_hours_downstream).to eq 0
        expect(updated_project_result.qty_hours_bug).to eq 0
        expect(updated_project_result.qty_bugs_closed).to eq 0
        expect(updated_project_result.qty_bugs_opened).to eq 0
        expect(updated_project_result.flow_pressure.to_f).to eq 0.0
        expect(updated_project_result.remaining_days).to eq 0
        expect(updated_project_result.cost_in_week.to_f).to eq 200
        expect(updated_project_result.average_demand_cost.to_f).to eq 200.0
        expect(updated_project_result.available_hours.to_f).to eq 30

        expect(created_project_result.demands).to eq [updated_demand]
        expect(created_project_result.project).to eq project
        expect(created_project_result.team).to eq team
        expect(created_project_result.result_date).to eq end_date.to_date
        expect(created_project_result.known_scope).to eq 1
        expect(created_project_result.throughput).to eq 1
        expect(created_project_result.qty_hours_upstream).to eq 0
        expect(created_project_result.qty_hours_downstream).to eq 16
        expect(created_project_result.qty_hours_bug).to eq 16.0
        expect(created_project_result.qty_bugs_closed).to eq 1
        expect(created_project_result.qty_bugs_opened).to eq 0
        expect(created_project_result.flow_pressure.to_f).to eq 0.0169491525423729
        expect(created_project_result.remaining_days).to eq 59
        expect(created_project_result.cost_in_week.to_f).to eq 25.0
        expect(created_project_result.average_demand_cost.to_f).to eq 25.0
        expect(created_project_result.available_hours.to_f).to eq 30
      end
    end
  end
end
