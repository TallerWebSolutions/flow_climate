# frozen_string_literal: true

RSpec.describe Types::QueryType do
  describe 'teams' do
    subject(:result) do
      FlowClimateSchema.execute(query).as_json
    end

    describe '#teams' do
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
          Team.all.map do |team|
            {
              'id' => team.id.to_s,
              'name' => team.name,
              'company' => {
                'id' => company.id.to_s,
                'name' => company.name
              }
            }
          end
        )
      end
    end

    describe 'team' do
      it 'returns the team and its fields' do
        team = Fabricate :team
        project = Fabricate :project, team: team
        other_project = Fabricate :project, team: team

        Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
        second_replenishing_consolidation = Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6

        Fabricate :replenishing_consolidation, project: other_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
        second_other_replenishing_consolidation = Fabricate :replenishing_consolidation, project: other_project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6

        query =
          %(query {
        team(id: #{team.id}) {
          id
          name
          replenishingConsolidations(orderBy: "consolidation_date", direction: "asc", limit: 2) {
            id
            teamThroughputData
            averageTeamThroughput
            teamLeadTime
            teamWip
          }
        }
      })

        result = FlowClimateSchema.execute(query).as_json
        expect(result.dig('data', 'team')).to eq({
                                                   'id' => team.id.to_s,
                                                   'name' => team.name,
                                                   'replenishingConsolidations' =>
                                                     [
                                                       { 'id' => second_replenishing_consolidation.id.to_s, 'teamThroughputData' => [10, 9, 15], 'averageTeamThroughput' => 11, 'teamLeadTime' => 4.1, 'teamWip' => 6 },
                                                       { 'id' => second_other_replenishing_consolidation.id.to_s, 'teamThroughputData' => [10, 9, 15], 'averageTeamThroughput' => 11, 'teamLeadTime' => 4.1, 'teamWip' => 6 }
                                                     ]
                                                 })
      end
    end
  end
end
