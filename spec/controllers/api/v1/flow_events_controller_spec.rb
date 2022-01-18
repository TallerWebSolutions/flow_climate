# frozen_string_literal: true

RSpec.describe Api::V1::FlowEventsController, type: :controller do
  describe 'POST #create' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let!(:product) { Fabricate :product, company: company, customer: customer }
    let!(:project) { Fabricate :project, company: company, products: [product] }

    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        let!(:demand) { Fabricate :demand, company: company, product: product, project: project }

        it 'creates the flow event' do
          request.headers.merge! headers
          post :create, params: { company_id: company.id, flow_event: { project_id: project.id, event_type: :api_not_ready, event_size: :medium, event_description: 'foo bar', event_date: Time.zone.local(2019, 4, 2, 12, 38, 0) } }

          expect(response).to have_http_status :ok

          flow_event = FlowEvent.last
          expect(flow_event.project).to eq project
          expect(flow_event.event_type).to eq 'api_not_ready'
          expect(flow_event.event_size).to eq 'medium'
          expect(flow_event.event_description).to eq 'foo bar'
          expect(flow_event.event_date).to eq Time.zone.local(2019, 4, 2, 12, 38, 0)
        end
      end
    end

    context 'with invalid' do
      context 'parameters' do
        it 'responds bad_request' do
          request.headers.merge! headers
          post :create, params: { company_id: company, flow_event: { demand_id: '' } }

          expect(response).to have_http_status :bad_request
          expect(JSON.parse(response.body)['data']).to eq ['Data do Evento não pode ficar em branco | Tipo do Evento não pode ficar em branco | Descrição do Evento não pode ficar em branco'].join(' | ')
          expect(JSON.parse(response.body)['message']).to eq I18n.t('flow_events.create.error')
        end
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        post :create, params: { company_id: 'foo' }

        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #opened_events' do
    before { travel_to Time.zone.local(2019, 10, 17, 11, 20, 0) }

    let(:company) { Fabricate :company }
    let!(:project) { Fabricate :project, company: company }

    let!(:headers) { { HTTP_API_TOKEN: company.api_token } }

    context 'authenticated' do
      context 'with valid parameters' do
        let(:demand) { Fabricate :demand }
        let!(:flow_event) { Fabricate :flow_event, company: company, event_date: 2.days.ago }
        let!(:other_flow_event) { Fabricate :flow_event, company: company, event_date: 3.days.ago }

        it 'returns the events that were opened' do
          request.headers.merge! headers
          get :opened_events, params: { company_id: company.id }

          expect(response).to have_http_status :ok

          expect(JSON.parse(response.body)['status']).to eq 'SUCCESS'
          expect(JSON.parse(response.body)['message']).to eq I18n.t('flow_events.opened_events.title', company_name: company.name)
          expect(JSON.parse(response.body)['data']).to eq([other_flow_event, flow_event].map { |event| event.to_hash.with_indifferent_access })
        end
      end
    end

    context 'unauthenticated' do
      it 'never calls the service to build the response and returns unauthorized' do
        get :opened_events, params: { company_id: company }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
