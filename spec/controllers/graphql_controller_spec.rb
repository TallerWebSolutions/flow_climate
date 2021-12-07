RSpec.describe GraphqlController, type: :controller do
  it 'returns the query result' do
    context 'with a valid team' do
      team = Fabricate :team

      query =
        %(query {
        team(id: #{team.id}) {
          id
        }
      })

      post :execute, params: { format: :json, query: query }

      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)).to eq({ 'data' => { 'team' => { 'id' => team.id.to_s} } })
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
