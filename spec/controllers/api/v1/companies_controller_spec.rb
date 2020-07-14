# frozen_string_literal: true

RSpec.describe Api::V1::CompaniesController, type: :controller do
  describe 'GET #show' do
    let(:company) { Fabricate :company }
    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        it 'calls the service to build the response' do
          request.headers.merge! headers
          get :show, params: { id: company.id }

          expect(JSON.parse(response.body)['data']['id']).to eq company.id
        end
      end
    end

    context 'with invalid company' do
      it 'never calls the service to build the response and returns unauthorized' do
        request.headers.merge! headers
        get :show, params: { id: 'foo' }

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
