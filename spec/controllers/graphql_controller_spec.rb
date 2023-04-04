# frozen_string_literal: true

RSpec.describe GraphqlController do
  context 'unauthenticated' do
    describe 'POST #execute' do
      before { post :execute, params: { format: :json, query: '' } }

      it { expect(response).to have_http_status :unauthorized }
    end
  end

  context 'authenticated as manager' do
    let(:user) { Fabricate :user }

    before { sign_in user }

    describe 'POST #execute' do
      context 'with a valid team' do
        it 'returns the query result' do
          team = Fabricate :team

          query =
            %(query {
              team(id: #{team.id}) {
                id
              }
            })

          post :execute, params: { format: :json, query: query }

          expect(response).to have_http_status :ok
          expect(response.parsed_body).to eq({ 'data' => { 'team' => { 'id' => team.id.to_s } } })
        end
      end

      context 'with an inexistent team' do
        it 'returns 404 with the correct message' do
          query =
            %(query {
              team(id: 43) {
                id
              }
            })

          post :execute, params: { format: :json, query: query }

          expect(response).to have_http_status :not_found
          expect(response.message).to eq('Not Found')
        end
      end
    end
  end

  context 'authenticated as customer' do
    let(:customer) { Fabricate :devise_customer }

    before { sign_in customer }

    describe 'POST #execute' do
      it 'returns the query result' do
        demand = Fabricate :demand

        query =
          %(
            query {
              demand(externalId: "#{demand.external_id}") {
                id
              }
            }
          )

        request.headers.merge(userprofile: 'customer')

        post :execute, params: { format: :json, query: query }

        expect(response).to have_http_status :ok
        expect(response.parsed_body.dig('data', 'demand', 'id')).to eq demand.id.to_s
      end
    end
  end
end
