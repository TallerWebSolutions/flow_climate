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
          company = Fabricate :company
          team = Fabricate :team, company: company
          customer = Fabricate :customer, company: company
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 4.days.ago, end_date: 1.day.from_now, max_work_in_progress: 2
          other_project = Fabricate :project, company: company, team: team, status: :executing, start_date: 2.days.ago, end_date: 4.days.from_now, max_work_in_progress: 4
          inactive_by_date_project = Fabricate :project, company: company, team: team, status: :executing, start_date: 2.days.ago, end_date: 1.day.ago
          inactive_by_status_project = Fabricate :project, company: company, team: team, status: :finished, start_date: 2.days.ago, end_date: 1.day.ago

          Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6, team_based_montecarlo_80_percent: 0.5, team_monte_carlo_weeks_max: 9, team_monte_carlo_weeks_min: 2, team_monte_carlo_weeks_std_dev: 2.1, team_based_odds_to_deadline: 0.9
          replenishing_consolidation = Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6, team_based_montecarlo_80_percent: 0.2, team_monte_carlo_weeks_max: 7, team_monte_carlo_weeks_min: 4, team_monte_carlo_weeks_std_dev: 4.1, team_based_odds_to_deadline: 0.7

          Fabricate :replenishing_consolidation, project: other_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6, team_based_montecarlo_80_percent: 0.6, team_monte_carlo_weeks_max: 8, team_monte_carlo_weeks_min: 1, team_monte_carlo_weeks_std_dev: 4.1, team_based_odds_to_deadline: 0.5
          other_replenishing_consolidation = Fabricate :replenishing_consolidation, project: other_project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6

          Fabricate :replenishing_consolidation, project: inactive_by_date_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
          Fabricate :replenishing_consolidation, project: inactive_by_status_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6

          Fabricate :project_consolidation, project: project, consolidation_date: 3.days.ago, project_throughput: 7
          Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, project_throughput: 10
          Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_throughput: 20

          Fabricate :project_consolidation, project: other_project, consolidation_date: 3.days.ago, project_throughput: 9
          Fabricate :project_consolidation, project: other_project, consolidation_date: 2.days.ago, project_throughput: 13
          Fabricate :project_consolidation, project: other_project, consolidation_date: 1.day.ago, project_throughput: 15

          query =
            %(query {
        me {
          id
          fullName
          avatar {
            imageSource
          }
        }
        team(id: #{team.id}) {
          id
          name
          throughputData
          averageThroughput
          increasedAvgThroughtput
          leadTime
          increasedLeadtime80
          workInProgress
          company {
            id
            name
          }
          lastReplenishingConsolidations {
            id
            customerHappiness
            createdAt
            project {
              id
              name
              startDate
              endDate
              aging
              remainingWeeks
              backlogCountFor
              remainingBacklog
              flowPressure
              flowPressurePercentage
              leadTimeP80
              qtySelected
              qtyInProgress
              monteCarloP80
              workInProgressLimit
              weeklyThroughputs
              modeWeeklyTroughputs
              stdDevWeeklyTroughputs
              teamMonteCarloP80
              teamMonteCarloWeeksMax
              teamMonteCarloWeeksMin
              teamMonteCarloWeeksStdDev
              teamBasedOddsToDeadline
              customers {
                name
              }
              products {
                name
              }
            }
          }
        }
      })

          user = Fabricate :user

          context = {
            current_user: user
          }

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
          expect(result.dig('data', 'me')).to eq({
                                                   'id' => user.id.to_s,
                                                   'fullName' => user.full_name,
                                                   'avatar' => {
                                                     'imageSource' => user.avatar.url
                                                   }
                                                 })

          expect(result.dig('data', 'team')).to eq({
                                                     'id' => team.id.to_s,
                                                     'name' => team.name,
                                                     'averageThroughput' => 11.333333333333334,
                                                     'increasedAvgThroughtput' => true,
                                                     'throughputData' => [10, 9, 15],
                                                     'leadTime' => 4.1,
                                                     'increasedLeadtime80' => false,
                                                     'workInProgress' => 6,
                                                     'company' => {
                                                       'id' => company.id.to_s,
                                                       'name' => company.name
                                                     },
                                                     'lastReplenishingConsolidations' => [
                                                       {
                                                         'id' => replenishing_consolidation.id.to_s,
                                                         'customerHappiness' => 1.4,
                                                         'createdAt' => replenishing_consolidation.created_at.iso8601,
                                                         'project' => {
                                                           'id' => project.id.to_s,
                                                           'name' => project.name,
                                                           'startDate' => project.start_date.iso8601,
                                                           'endDate' => project.end_date.iso8601,
                                                           'aging' => project.aging,
                                                           'remainingWeeks' => project.remaining_weeks,
                                                           'backlogCountFor' => project.backlog_count_for,
                                                           'remainingBacklog' => project.remaining_backlog,
                                                           'flowPressure' => project.flow_pressure.to_f,
                                                           'flowPressurePercentage' => project.relative_flow_pressure_in_replenishing_consolidation.to_f,
                                                           'qtySelected' => project.qty_selected_in_week,
                                                           'leadTimeP80' => project.general_leadtime.to_f,
                                                           'qtyInProgress' => project.in_wip.count,
                                                           'monteCarloP80' => project.monte_carlo_p80.to_f,
                                                           'workInProgressLimit' => project.max_work_in_progress,
                                                           'weeklyThroughputs' => project.last_weekly_throughput,
                                                           'modeWeeklyTroughputs' => 3,
                                                           'stdDevWeeklyTroughputs' => 4.949747468305833,
                                                           'teamMonteCarloP80' => 0.2,
                                                           'teamMonteCarloWeeksMax' => 7.0,
                                                           'teamMonteCarloWeeksMin' => 4.0,
                                                           'teamMonteCarloWeeksStdDev' => 4.1,
                                                           'teamBasedOddsToDeadline' => 0.7,
                                                           'customers' => [{ 'name' => customer.name }],
                                                           'products' => [{ 'name' => product.name }]
                                                         }
                                                       },
                                                       {
                                                         'id' => other_replenishing_consolidation.id.to_s,
                                                         'customerHappiness' => 1.4,
                                                         'createdAt' => other_replenishing_consolidation.created_at.iso8601,
                                                         'project' => {
                                                           'id' => other_project.id.to_s,
                                                           'name' => other_project.name,
                                                           'startDate' => other_project.start_date.iso8601,
                                                           'endDate' => other_project.end_date.iso8601,
                                                           'aging' => other_project.aging,
                                                           'backlogCountFor' => other_project.backlog_count_for,
                                                           'remainingWeeks' => other_project.remaining_weeks,
                                                           'remainingBacklog' => other_project.remaining_backlog,
                                                           'flowPressure' => other_project.flow_pressure,
                                                           'flowPressurePercentage' => other_project.relative_flow_pressure_in_replenishing_consolidation,
                                                           'qtySelected' => other_project.qty_selected_in_week,
                                                           'leadTimeP80' => other_project.general_leadtime,
                                                           'qtyInProgress' => other_project.in_wip.count,
                                                           'monteCarloP80' => other_project.monte_carlo_p80,
                                                           'workInProgressLimit' => other_project.max_work_in_progress,
                                                           'weeklyThroughputs' => other_project.last_weekly_throughput,
                                                           'modeWeeklyTroughputs' => 4,
                                                           'stdDevWeeklyTroughputs' => 1.4142135623730951,
                                                           'teamMonteCarloP80' => 10.1,
                                                           'teamMonteCarloWeeksMax' => 20,
                                                           'teamMonteCarloWeeksMin' => 4,
                                                           'teamMonteCarloWeeksStdDev' => 1.2,
                                                           'teamBasedOddsToDeadline' => 0.92,
                                                           'customers' => [],
                                                           'products' => []
                                                         }
                                                       }
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
