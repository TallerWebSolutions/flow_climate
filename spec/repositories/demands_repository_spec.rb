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

      expect(Demand.last.effort).to eq 30
      expect(Demand.last.demand_type).to eq 'bug'
      expect(Demand.last.created_date).to eq created_date
      expect(Demand.last.commitment_date).to eq commitment_date
      expect(Demand.last.end_date).to eq end_date
    end
  end
end
