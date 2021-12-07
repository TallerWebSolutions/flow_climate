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
          wipLimit
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
              'wipLimit' => team.max_work_in_progress,
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

        Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago
        second_consolidation = Fabricate :project_consolidation, project: project, consolidation_date: Time.zone.today

        Fabricate :project_consolidation, project: other_project, consolidation_date: 1.day.ago
        second_other_consolidation = Fabricate :project_consolidation, project: other_project, consolidation_date: Time.zone.today

        Fabricate :team_consolidation, team: team, consolidation_date: 2.days.ago, qty_demands_finished_upstream_in_week: 2, qty_demands_finished_downstream_in_week: 4
        Fabricate :team_consolidation, team: team, consolidation_date: 1.day.ago, qty_demands_finished_upstream_in_week: 5, qty_demands_finished_downstream_in_week: 1
        Fabricate :team_consolidation, team: team, consolidation_date: Time.zone.today, qty_demands_finished_upstream_in_week: 8, qty_demands_finished_downstream_in_week: 10

        query =
          %(query {
        team(id: #{team.id}) {
          id
          name
          wipLimit
          teamThroughputs
          projectConsolidations {
            id
          }
        }
      })

        result = FlowClimateSchema.execute(query).as_json
        expect(result.dig('data', 'team')).to eq({
                                                   'id' => team.id.to_s,
                                                   'name' => team.name,
                                                   'wipLimit' => team.max_work_in_progress,
                                                   'teamThroughputs' => [6, 6, 18],
                                                   'projectConsolidations' =>
                                                     [
                                                       { 'id' => second_consolidation.id.to_s },
                                                       { 'id' => second_other_consolidation.id.to_s }
                                                     ]
                                                 })
      end
    end
  end
end
