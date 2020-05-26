# frozen_string_literal: true

RSpec.describe Api::V1::DemandsController, type: :controller do
  describe 'GET #show' do
    let(:company) { Fabricate :company }
    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    let!(:team) { Fabricate :team, company: company }
    let!(:demand) { Fabricate :demand, team: team, external_id: 'AbC-302', demand_score: 10.5 }

    context 'authenticated' do
      context 'with valid parameters' do
        it 'calls the service to build the response' do
          request.headers.merge! headers
          get :show, params: { id: 'abc-302' }

          expect(JSON.parse(response.body)['data']['id']).to eq demand.id
          expect(JSON.parse(response.body)['data']['demand_score']).to eq demand.demand_score.to_s
        end
      end
    end

    context 'with invalid team' do
      it 'never calls the service to build the response and returns unauthorized' do
        request.headers.merge! headers
        expect(TeamService.instance).not_to receive(:average_demand_cost_stats_info_hash)
        get :show, params: { id: 'foo' }

        expect(response).to have_http_status :not_found
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        expect(TeamService.instance).not_to receive(:average_demand_cost_stats_info_hash)
        get :show, params: { id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
