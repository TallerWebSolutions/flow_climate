# frozen_string_literal: true

RSpec.describe Types::QueryType do
  describe 'teams' do
    subject(:result) do
      FlowClimateSchema.execute(query).as_json
    end

    describe '#items' do
      let(:query) do
        %(query {
        teams {
          id
          name
          company {
            id
            name
          }
        }
      })
      end

      it 'returns all teams' do
        company = Fabricate :company
        Fabricate :team, company: company
        Fabricate :team, company: company

        expect(result.dig('data', 'teams')).to match_array(
                                                 Team.all.map { |team| { 'id' => team.id.to_s, 'name' => team.name, company: { 'id' => company.id, 'name' => company.name } } }
        )
      end
    end
  end
end
