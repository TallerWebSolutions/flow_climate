# frozen_string_literal: true

RSpec.describe Api::V1::DemandsController do
  describe 'GET #show' do
    let(:company) { Fabricate :company }
    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    let!(:demand) { Fabricate :demand, company: company, external_id: 'AbC-302', demand_score: 10.5 }

    context 'authenticated' do
      context 'with valid parameters' do
        it 'calls the service to build the response' do
          request.headers.merge! headers
          get :show, params: { id: 'abc-302' }

          expect(response.parsed_body['data']['id']).to eq demand.id
          expect(response.parsed_body['data']['demand_score']).to eq demand.demand_score.to_s
        end
      end
    end

    context 'with not existent demand' do
      it 'never calls the service to build the response and returns unauthorized' do
        request.headers.merge! headers
        get :show, params: { id: 'foo' }

        expect(response).to have_http_status :not_found
      end
    end

    context 'with demand in other company' do
      it 'never calls the service to build the response and returns unauthorized' do
        other_company = Fabricate :company
        Fabricate :demand, company: other_company, external_id: 'foobar', demand_score: 10.5

        request.headers.merge! headers
        get :show, params: { id: 'foobar' }

        expect(response).to have_http_status :not_found
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        get :show, params: { id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
