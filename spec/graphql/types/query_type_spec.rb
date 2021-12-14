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
          throughputData
          averageThroughput
          increasedAvgThroughtput
          leadTime
          increasedLeadtime80
          workInProgress,
          lastReplenishingConsolidations(orderBy: "consolidation_date", direction: "asc", limit: 1) {
            id
            project {
              id
              name
              remainingWeeks
              remainingBacklog
              flowPressure
              flowPressurePercentage
              leadTimeP80
              qtySelected
              qtyInProgress
              monteCarloP80
            }
          }
        }
      })

          result = FlowClimateSchema.execute(query).as_json
          expect(result.dig('data', 'team')).to eq({
                                                     'id' => team.id.to_s,
                                                     'name' => team.name,
                                                     'averageThroughput' => 11.333333333333334,
                                                     'increasedAvgThroughtput' => true,
                                                     'throughputData' => [10, 9, 15],
                                                     'leadTime' => 4.1,
                                                     'increasedLeadtime80' => false,
                                                     'workInProgress' => 6,
                                                     'lastReplenishingConsolidations' => [
                                                       { 'id' => replenishing_consolidation.id.to_s,
                                                         'project' => {
                                                           'id' => project.id.to_s,
                                                           'name' => project.name,
                                                           'remainingWeeks' => project.remaining_weeks,
                                                           'remainingBacklog' => project.remaining_backlog,
                                                           'flowPressure' => project.flow_pressure.to_f,
                                                           'flowPressurePercentage' => project.relative_flow_pressure_in_replenishing_consolidation.to_f,
                                                           'qtySelected' => project.qty_selected_in_week,
                                                           'leadTimeP80' => project.general_leadtime.to_f,
                                                           'qtyInProgress' => project.in_wip.count,
                                                           'monteCarloP80' => project.monte_carlo_p80.to_f
                                                         } },
                                                       { 'id' => other_replenishing_consolidation.id.to_s,
                                                         'project' => {
                                                           'id' => other_project.id.to_s,
                                                           'name' => other_project.name,
                                                           'remainingWeeks' => other_project.remaining_weeks,
                                                           'remainingBacklog' => other_project.remaining_backlog,
                                                           'flowPressure' => other_project.flow_pressure,
                                                           'flowPressurePercentage' => other_project.relative_flow_pressure_in_replenishing_consolidation,
                                                           'qtySelected' => other_project.qty_selected_in_week,
                                                           'leadTimeP80' => other_project.general_leadtime,
                                                           'qtyInProgress' => other_project.in_wip.count,
                                                           'monteCarloP80' => other_project.monte_carlo_p80
                                                         } }
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
          throughputData
          averageThroughput
          leadTime
          workInProgress,
          lastReplenishingConsolidations {
            id
          }
        }
      })

          result = FlowClimateSchema.execute(query).as_json
          expect(result.dig('data', 'team')).to eq({
                                                     'id' => team.id.to_s,
                                                     'name' => team.name,
                                                     'averageThroughput' => nil,
                                                     'leadTime' => nil,
                                                     'throughputData' => nil,
                                                     'workInProgress' => nil,
                                                     'lastReplenishingConsolidations' => []
                                                   })
        end
      end
    end
  end
end
