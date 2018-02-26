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

  describe '#create_or_update_demand' do
    let(:company) { Fabricate :company }
    let!(:project) { Fabricate :project, start_date: Time.zone.local(2018, 2, 12, 14, 0, 0), end_date: Time.zone.local(2018, 2, 20, 16, 0, 0) }

    context 'when the demand does not exist' do
      it 'creates the demand and the project result' do
        DemandsRepository.instance.create_or_update_demand(project, '100', 'bug', 'bla.xpto.com')

        created_demand = Demand.last
        expect(created_demand.demand_id).to eq '100'
        expect(created_demand.demand_type).to eq 'bug'
        expect(created_demand.url).to eq 'bla.xpto.com'
      end
    end
    context 'when the demand exist' do
      let(:project) { Fabricate :project, start_date: Time.iso8601('2018-01-11T23:01:46-02:00'), end_date: Time.iso8601('2018-02-20T23:01:46-02:00') }
      let!(:demand) { Fabricate :demand, demand_id: '100', effort: 25 }

      it 'updates the demand' do
        DemandsRepository.instance.create_or_update_demand(project, 1, :bug, 'bla.xpto.com')
        updated_demand = Demand.last
        expect(updated_demand.demand_id).to eq '1'
        expect(updated_demand.demand_type).to eq 'bug'
        expect(updated_demand.url).to eq 'bla.xpto.com'
      end
    end
  end
end
