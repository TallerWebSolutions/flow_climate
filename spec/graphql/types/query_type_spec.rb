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
      context 'with replenishing consolidations' do
        it 'returns the team and its fields' do
          team = Fabricate :team
          project = Fabricate :project, team: team, status: :executing, start_date: 4.days.ago, end_date: 1.day.from_now
          other_project = Fabricate :project, team: team, status: :executing, start_date: 2.days.ago, end_date: 4.days.from_now
          inactive_by_date_project = Fabricate :project, team: team, status: :executing, start_date: 2.days.ago, end_date: 1.day.ago
          inactive_by_status_project = Fabricate :project, team: team, status: :finished, start_date: 2.days.ago, end_date: 1.day.ago

          Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
          replenishing_consolidation = Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6

          Fabricate :replenishing_consolidation, project: other_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
          other_replenishing_consolidation = Fabricate :replenishing_consolidation, project: other_project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6

          Fabricate :replenishing_consolidation, project: inactive_by_date_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
          Fabricate :replenishing_consolidation, project: inactive_by_status_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6

          query =
            %(query {
        team(id: #{team.id}) {
          id
          name
          teamThroughputData
          averageTeamThroughput
          teamLeadTime
          teamWip,
          replenishingConsolidations {
            id
          }
        }
      })

          result = FlowClimateSchema.execute(query).as_json
          expect(result.dig('data', 'team')).to eq({
                                                     'id' => team.id.to_s,
                                                     'name' => team.name,
                                                     'averageTeamThroughput' => 11.333333333333334,
                                                     'teamThroughputData' => [10, 9, 15],
                                                     'teamLeadTime' => 4.1,
                                                     'teamWip' => 6,
                                                     'replenishingConsolidations' => [
                                                       { 'id' => replenishing_consolidation.id.to_s },
                                                       { 'id' => other_replenishing_consolidation.id.to_s }
                                                     ]
                                                   })
        end
      end

      context 'without replenishing consolidations' do
        it 'returns the team and its fields' do
          team = Fabricate :team
          Fabricate :project, team: team, status: :executing, start_date: 4.days.ago, end_date: 1.day.from_now
          Fabricate :project, team: team, status: :executing, start_date: 2.days.ago, end_date: 4.days.from_now

          query =
            %(query {
        team(id: #{team.id}) {
          id
          name
          teamThroughputData
          averageTeamThroughput
          teamLeadTime
          teamWip,
          replenishingConsolidations {
            id
          }
        }
      })

          result = FlowClimateSchema.execute(query).as_json
          expect(result.dig('data', 'team')).to eq({
                                                     'id' => team.id.to_s,
                                                     'name' => team.name,
                                                     'averageTeamThroughput' => nil,
                                                     'teamLeadTime' => nil,
                                                     'teamThroughputData' => nil,
                                                     'teamWip' => nil,
                                                     'replenishingConsolidations' => []
                                                   })
        end
      end
    end
  end
end
