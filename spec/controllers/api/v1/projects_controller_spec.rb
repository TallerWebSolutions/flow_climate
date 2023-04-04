# frozen_string_literal: true

RSpec.describe Api::V1::ProjectsController do
  describe 'GET #show' do
    let(:company) { Fabricate :company }
    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        it 'calls the service to build the response' do
          project = Fabricate :project, company: company
          request.headers.merge! headers
          get :show, params: { id: project.id }

          expect(response.parsed_body['data']['id']).to eq project.id
        end
      end
    end

    context 'with invalid project' do
      it 'never calls the service to build the response and returns unauthorized' do
        project = Fabricate :project

        request.headers.merge! headers
        get :show, params: { id: project.id }

        expect(response).to have_http_status :not_found
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        project = Fabricate :project, company: company

        get :show, params: { id: project.id }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
