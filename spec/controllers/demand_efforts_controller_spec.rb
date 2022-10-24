# frozen_string_literal: true

RSpec.describe DemandEffortsController do
  context 'unauthenticated' do
    describe '#index' do
      before { get :index, params: { company_id: 'foo', demand_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe '#index' do
      context 'with valid params' do
        context 'with data' do
          it 'downloads the csv file' do
            demand = Fabricate :demand, company: company
            effort = Fabricate :demand_effort, demand: demand
            other_effort = Fabricate :demand_effort, demand: demand

            get :index, params: { company_id: company, demand_id: demand }, format: :csv

            csv = CSV.parse(response.body, headers: true)
            expect(csv.count).to eq 2
            expect(csv.pluck(0)).to match_array [effort.demand.external_id, other_effort.demand.external_id]
          end
        end

        context 'with no data' do
          it 'downloads the csv file' do
            demand = Fabricate :demand, company: company

            get :index, params: { company_id: company, demand_id: demand }, format: :csv

            csv = CSV.parse(response.body, headers: true)
            expect(csv.count).to eq 0
          end
        end
      end

      context 'with invalid params' do
        context 'demand' do
          before { get :index, params: { company_id: company, demand_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          let(:demand) { Fabricate :demand }

          context 'not found' do
            before { get :index, params: { company_id: 'foo', demand_id: demand } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            before { get :index, params: { company_id: demand.company, demand_id: demand } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
