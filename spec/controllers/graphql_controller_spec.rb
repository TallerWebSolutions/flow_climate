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

    before { login_as user }

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
end
