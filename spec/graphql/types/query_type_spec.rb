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
        }
      })
      end

      it 'returns all items' do
        Fabricate :team
        Fabricate :team

        expect(result.dig('data', 'teams')).to match_array(
                                                 Team.all.map { |team| { 'id' => team.id.to_s, 'name' => team.name } }
        )
      end
    end
  end
end
