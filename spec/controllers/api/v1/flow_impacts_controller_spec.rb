# frozen_string_literal: true

RSpec.describe Api::V1::FlowImpactsController, type: :controller do
  describe 'POST #create' do
    let(:company) { Fabricate :company }
    let!(:project) { Fabricate :project, company: company }

    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        let!(:demand) { Fabricate :demand, project: project }

        it 'creates the flow impact' do
          request.headers.merge! headers
          post :create, params: { project_id: project.id, flow_impact: { demand_id: demand.external_id, impact_type: :api_not_ready, impact_description: 'foo bar', start_date: Time.zone.local(2019, 4, 2, 12, 38, 0), end_date: Time.zone.local(2019, 4, 2, 15, 38, 0) } }

          expect(response).to have_http_status :ok

          flow_impact = FlowImpact.last
          expect(flow_impact.project).to eq project
          expect(flow_impact.demand).to eq demand
          expect(flow_impact.impact_type).to eq 'api_not_ready'
          expect(flow_impact.impact_description).to eq 'foo bar'
          expect(flow_impact.start_date).to eq Time.zone.local(2019, 4, 2, 12, 38, 0)
          expect(flow_impact.end_date).to eq Time.zone.local(2019, 4, 2, 15, 38, 0)
        end
      end
    end

    context 'with invalid' do
      context 'project' do
        it 'responds 404' do
          request.headers.merge! headers
          post :create, params: { project_id: 'foo' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'parameters' do
        it 'responds bad_request' do
          request.headers.merge! headers
          post :create, params: { project_id: project, flow_impact: { demand_id: '' } }

          expect(response).to have_http_status :bad_request
          expect(JSON.parse(response.body)['data']).to eq ['Iniciou em não pode ficar em branco', 'Tipo do Impacto não pode ficar em branco', 'Descrição do Impacto não pode ficar em branco'].join(' | ')
          expect(JSON.parse(response.body)['message']).to eq I18n.t('flow_impacts.create.error')
        end
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        post :create, params: { project_id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #opened_impacts' do
    before { travel_to Time.zone.local(2019, 10, 17, 11, 20, 0) }

    after { travel_back }

    let(:company) { Fabricate :company }
    let!(:project) { Fabricate :project, company: company }

    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        let(:demand) { Fabricate :demand }
        let!(:flow_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 2.days.ago, end_date: nil }
        let!(:other_flow_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 3.days.ago, end_date: nil }
        let!(:closed_flow_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 3.days.ago, end_date: 1.day.ago }

        it 'returns the opened impacts' do
          request.headers.merge! headers
          get :opened_impacts, params: { project_id: project.id }

          expect(response).to have_http_status :ok

          expect(JSON.parse(response.body)['status']).to eq 'SUCCESS'
          expect(JSON.parse(response.body)['message']).to eq I18n.t('flow_impacts.opened_impacts.title', project_name: project.name)
          expect(JSON.parse(response.body)['data']).to eq([other_flow_impact, flow_impact].map { |impact| impact.to_hash.with_indifferent_access })

          # "data"=>[{"project_name"=>"DrMilissaOberbrunner", "impact_type"=>"Cliente indisponível", "demand"=>"15456", "start_date"=>"2019-10-14T18:32:58-03:00", "end_date"=>nil, "impact_duration"=>259200.019526}, {"project_name"=>"DrMilissaOberbrunner", "impact_type"=>"Dependência de outro time", "demand"=>"15456", "start_date"=>"2019-10-15T18:32:58-03:00", "end_date"=>nil, "impact_duration"=>172800.045901}]}
        end
      end
    end

    context 'with invalid' do
      context 'project' do
        it 'responds 404' do
          request.headers.merge! headers
          get :opened_impacts, params: { project_id: 'foo' }

          expect(response).to have_http_status :not_found
        end
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        get :opened_impacts, params: { project_id: project.id }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
