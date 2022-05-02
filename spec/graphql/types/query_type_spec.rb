# frozen_string_literal: true

RSpec.describe Types::QueryType do
  describe '#teams' do
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

      context 'when the user has no a last company setted' do
        it 'returns nothing' do
          user = Fabricate :user

          context = {
            current_user: user
          }

          company = Fabricate :company
          other_company = Fabricate :company

          Fabricate :team, company: company
          Fabricate :team, company: company
          Fabricate :team, company: other_company

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
          expect(result.dig('data', 'teams')).to be_nil
        end
      end

      context 'when the user has last company setted' do
        it 'returns nothing' do
          company = Fabricate :company
          other_company = Fabricate :company

          user = Fabricate :user, companies: [company], last_company_id: company.id

          context = {
            current_user: user
          }

          Fabricate :team, company: company
          Fabricate :team, company: company
          Fabricate :team, company: other_company

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
          expect(result.dig('data', 'teams')).to match_array(
            company.teams.map do |team|
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
    end

    describe '#team' do
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
          language
          currentCompany {
            name
          }
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

          user = Fabricate :user, companies: [company], last_company_id: company.id

          context = {
            current_user: user
          }

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
          expect(result.dig('data', 'me')).to eq({
                                                   'id' => user.id.to_s,
                                                   'fullName' => user.full_name,
                                                   'language' => user.language,
                                                   'currentCompany' => {
                                                     'name' => user.last_company&.name
                                                   },
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

  describe '#project' do
    context 'with project' do
      it 'returns the project and its fields' do
        company = Fabricate :company
        team = Fabricate :team, company: company
        customer = Fabricate :customer, company: company
        product = Fabricate :product, company: company, customer: customer
        project = Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: Time.zone.parse('2022-04-23 10:51'), end_date: 1.day.from_now, max_work_in_progress: 2
        Fabricate :demand, company: company, project: project, team: team
        first_finished_demand = Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: Time.zone.parse('2022-04-15 12:30')
        second_finished_demand = Fabricate :demand, project: project, demand_type: :bug, created_date: Time.zone.parse('2022-04-23 13:30'), commitment_date: Time.zone.parse('2022-04-24 10:30'), end_date: Time.zone.parse('2022-04-25 17:30')
        project_consolidation = Fabricate :project_consolidation, project: project, monte_carlo_weeks_min: 9, monte_carlo_weeks_max: 85, monte_carlo_weeks_std_dev: 7, team_based_operational_risk: 0.5, consolidation_date: Time.zone.today
        demand = Fabricate :demand, company: company, project: project, team: team
        Fabricate :demand_block, demand: demand

        team_member = Fabricate :team_member, company: company, name: 'foo'
        membership = Fabricate :membership, team: team, team_member: team_member
        Fabricate :item_assignment, demand: first_finished_demand, membership: membership
        Fabricate :item_assignment, demand: second_finished_demand, membership: membership

        query =
          %(query {
        me {
          id
          fullName
          companies {
            id
            name
            slug
          }
          avatar {
            imageSource
          }
          admin
        }
        project(id: #{project.id}) {
          id
          name
          startDate
          endDate
          deadlinesChangeCount
          discoveredScope
          company {
            id
            name
          }
          projectConsolidations {
            id
            leadTimeHistogramBinMin
            leadTimeHistogramBinMax
            leadTimeMinMonth
            leadTimeMaxMonth
            interquartileRange
            leadTimeP25
            leadTimeP75
          }
          pastWeeks
          remainingWork
          currentWeeksByLittleLaw
          currentMonteCarloWeeksMin
          currentMonteCarloWeeksMax
          currentMonteCarloWeeksStdDev
          currentTeamBasedRisk
          currentRiskToDeadline
          remainingDays
          running
          leadTimeP65
          leadTimeP95
          numberOfDemandsDelivered
          numberOfDemands
          numberOfDownstreamDemands
          currentWeeklyHoursIdealBurnup
          demandBlocks {
            id
          }
          unscoredDemands {
            id
          }
          demandsFinishedWithLeadtime {
            id
          }
          discardedDemands {
            id
          }
          hoursPerStageChartData {
            xAxis
            yAxis
          }
          projectConsolidationsWeekly {
            id
          }
          projectConsolidationsLastMonth {
            id
          }
          lastProjectConsolidationsWeekly {
            id
          }
          demandsFlowChartData {
            committedChartData
            creationChartData
            pullTransactionRate
            throughputChartData
          }
          cumulativeFlowChartData {
            xAxis
            yAxis {
              name
              data
            }
          }
          leadTimeHistogramData {
            keys
            values
          }
          projectMembers {
            demandsCount
            memberName
          }
        }

        projectConsolidations(projectId: #{project.id}) {
          id
          leadTimeHistogramBinMin
          leadTimeHistogramBinMax
          leadTimeMinMonth
          leadTimeMaxMonth
          interquartileRange
          leadTimeP25
          leadTimeP75
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
                                                 'companies' => [],
                                                 'admin' => false,
                                                 'avatar' => {
                                                   'imageSource' => user.avatar.url
                                                 }
                                               })

        expect(result.dig('data', 'project')).to eq({
                                                      'id' => project.id.to_s,
                                                      'name' => project.name,
                                                      'startDate' => project.start_date.to_s,
                                                      'endDate' => project.end_date.to_s,
                                                      'deadlinesChangeCount' => 0,
                                                      'discoveredScope' => nil,
                                                      'pastWeeks' => project.past_weeks.to_i,
                                                      'currentWeeksByLittleLaw' => 0,
                                                      'currentMonteCarloWeeksMin' => 9,
                                                      'currentMonteCarloWeeksMax' => 85,
                                                      'currentMonteCarloWeeksStdDev' => 7,
                                                      'remainingWork' => 28,
                                                      'currentTeamBasedRisk' => 0.5,
                                                      'currentRiskToDeadline' => 0.0,
                                                      'remainingDays' => project.remaining_days,
                                                      'currentWeeklyHoursIdealBurnup' => project.current_weekly_hours_ideal_burnup,
                                                      'running' => true,
                                                      'company' => {
                                                        'id' => company.id.to_s,
                                                        'name' => company.name
                                                      },
                                                      'projectConsolidations' => [{
                                                        'id' => project_consolidation.id.to_s,
                                                        'interquartileRange' => 0.0,
                                                        'leadTimeHistogramBinMax' => 0.0,
                                                        'leadTimeHistogramBinMin' => 0.0,
                                                        'leadTimeMaxMonth' => 0.0,
                                                        'leadTimeMinMonth' => 0.0,
                                                        'leadTimeP25' => project_consolidation.lead_time_p65,
                                                        'leadTimeP75' => project_consolidation.lead_time_p75
                                                      }],
                                                      'demandsFinishedWithLeadtime' => [{ 'id' => second_finished_demand.id.to_s }],
                                                      'discardedDemands' => [],
                                                      'unscoredDemands' => project.demands.kept.unscored_demands.map do |unscored_demand|
                                                        {
                                                          'id' => unscored_demand.id.to_s
                                                        }
                                                      end,
                                                      'demandBlocks' => demand.demand_blocks.map do |demand_block|
                                                        {
                                                          'id' => demand_block.id.to_s
                                                        }
                                                      end,
                                                      'numberOfDemands' => project.demands.count,
                                                      'leadTimeP65' => project.general_leadtime(65),
                                                      'leadTimeP95' => project.general_leadtime(95),
                                                      'numberOfDemandsDelivered' => project.demands.kept.finished_until_date(Time.zone.now).count,
                                                      'numberOfDownstreamDemands' => 0,
                                                      'hoursPerStageChartData' => {
                                                        'xAxis' => [],
                                                        'yAxis' => []
                                                      },
                                                      'projectConsolidationsWeekly' => [
                                                        {
                                                          'id' => project_consolidation.id.to_s
                                                        }
                                                      ],
                                                      'projectConsolidationsLastMonth' => [
                                                        {
                                                          'id' => project_consolidation.id.to_s
                                                        }
                                                      ],
                                                      'lastProjectConsolidationsWeekly' => nil,
                                                      'demandsFlowChartData' => { 'committedChartData' => [0, 0, 0], 'creationChartData' => [1, 2, 0], 'pullTransactionRate' => [0, 0, 0], 'throughputChartData' => [0, 1, 0] },
                                                      'cumulativeFlowChartData' => { 'xAxis' => %w[2022-04-24 2022-05-01 2022-05-08], 'yAxis' => [] },
                                                      'leadTimeHistogramData' => {
                                                        'keys' => [111_600.0],
                                                        'values' => [1]
                                                      },
                                                      'projectMembers' => [{
                                                        'demandsCount' => 2,
                                                        'memberName' => 'foo'
                                                      }]
                                                    })
        expect(result.dig('data', 'projectConsolidations')).to eq([{
                                                                    'id' => project_consolidation.id.to_s,
                                                                    'interquartileRange' => 0.0,
                                                                    'leadTimeHistogramBinMax' => 0.0,
                                                                    'leadTimeHistogramBinMin' => 0.0,
                                                                    'leadTimeMaxMonth' => 0.0,
                                                                    'leadTimeMinMonth' => 0.0,
                                                                    'leadTimeP25' => 0.0,
                                                                    'leadTimeP75' => 0.0
                                                                  }])
      end
    end
  end

  describe '#demands' do
    context 'with blocks' do
      it 't' do
        company = Fabricate :company
        team = Fabricate :team, company: company
        customer = Fabricate :customer, company: company
        product = Fabricate :product, company: company, customer: customer
        project = Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 10.days.ago, end_date: 5.days.from_now, max_work_in_progress: 4
        demand = Fabricate :demand, company: company, project: project, team: team
        Fabricate :demand_block, demand: demand

        query =
          %(
        query {
          demands(projectId: #{project.id}, limit: 1, finished: false) {
            numberOfBlocks
          }
        }
      )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'demands')).to eq([{
                                                      'numberOfBlocks' => 1
                                                    }])
      end
    end
  end

  describe '#tasks' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:initiative) { Fabricate :initiative, company: company }
    let(:project) { Fabricate :project, company: company, initiative: initiative, team: team }

    let(:first_demand) { Fabricate :demand, company: company, project: project, team: team }
    let(:second_demand) { Fabricate :demand, company: company, project: project, team: team }

    let(:query) do
      %(query {
        tasksList(pageNumber: 1, limit: 3, title: "bar") {
          totalCount
          totalDeliveredCount
          lastPage
          totalPages
          deliveredLeadTimeP65
          deliveredLeadTimeP80
          deliveredLeadTimeP95
          inProgressLeadTimeP65
          inProgressLeadTimeP80
          inProgressLeadTimeP95
          tasks {
            id
            title
            delivered
            initiative {
              id
            }
            project {
              id
            }
            demand {
              id
              demandTitle
            }
            team {
              id
            }
            company {
              id
            }
          }
          tasksCharts {
            xAxis
            creationArray
            throughputArray
            completionPercentilesOnTimeArray
            accumulatedCompletionPercentilesOnTimeArray
          }
          completiontimeHistogramChartData {
            keys
            values
          }
        }
      })
    end

    context 'when the user has no a last company setted' do
      it 'returns nothing' do
        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
        expect(result.dig('data', 'tasksList')).to eq(
          {
            'deliveredLeadTimeP65' => 0,
            'deliveredLeadTimeP80' => 0,
            'deliveredLeadTimeP95' => 0,
            'inProgressLeadTimeP65' => 0,
            'inProgressLeadTimeP80' => 0,
            'inProgressLeadTimeP95' => 0,
            'lastPage' => false,
            'tasks' => [],
            'totalCount' => 0,
            'totalDeliveredCount' => 0,
            'totalPages' => 0,
            'tasksCharts' => {
              'xAxis' => [],
              'creationArray' => [],
              'throughputArray' => [],
              'completionPercentilesOnTimeArray' => [],
              'accumulatedCompletionPercentilesOnTimeArray' => []
            },
            'completiontimeHistogramChartData' => { 'keys' => [], 'values' => [] }
          }
        )
      end
    end

    context 'when the user has last company setted' do
      it 'returns the tasks' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          user = Fabricate :user, companies: [company], last_company_id: company.id

          context = {
            current_user: user
          }

          first_task = Fabricate :task, demand: first_demand, title: 'foo BaR', created_date: 2.days.ago, end_date: 2.days.ago
          second_task = Fabricate :task, demand: second_demand, title: 'BaR', created_date: 1.day.ago, end_date: 1.hour.ago
          third_task = Fabricate :task, demand: second_demand, title: 'BaR', created_date: 1.day.ago, end_date: nil
          Fabricate :task, demand: second_demand, title: 'BaRco', created_date: 3.days.ago, end_date: nil

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

          expect(result.dig('data', 'tasksList')['totalCount']).to eq 4
          expect(result.dig('data', 'tasksList')['totalDeliveredCount']).to eq 2
          expect(result.dig('data', 'tasksList')['lastPage']).to be false
          expect(result.dig('data', 'tasksList')['totalPages']).to eq 2
          expect(result.dig('data', 'tasksList')['deliveredLeadTimeP65']).to eq 53_820
          expect(result.dig('data', 'tasksList')['deliveredLeadTimeP80']).to eq 66_240
          expect(result.dig('data', 'tasksList')['deliveredLeadTimeP95']).to eq 78_660
          expect(result.dig('data', 'tasksList')['inProgressLeadTimeP65']).to eq 198_720
          expect(result.dig('data', 'tasksList')['inProgressLeadTimeP80']).to eq 224_640
          expect(result.dig('data', 'tasksList')['inProgressLeadTimeP95']).to eq 250_560
          expect(result.dig('data', 'tasksList')['tasksCharts']).to match_array(
            {
              'accumulatedCompletionPercentilesOnTimeArray' => [66_240.0],
              'completionPercentilesOnTimeArray' => [66_240.0],
              'creationArray' => [3],
              'throughputArray' => [2],
              'xAxis' => ['2022-03-27']
            }
          )

          expect(result.dig('data', 'tasksList', 'tasks')).to match_array(
            [first_task, second_task, third_task].map do |task|
              {
                'id' => task.id.to_s,
                'title' => task.title,
                'delivered' => task.end_date.present?,
                'initiative' => {
                  'id' => task.demand.project.initiative.id.to_s
                },
                'project' => {
                  'id' => task.demand.project.id.to_s
                },
                'demand' => {
                  'id' => task.demand.id.to_s,
                  'demandTitle' => task.demand.demand_title
                },
                'team' => {
                  'id' => task.demand.team.id.to_s
                },
                'company' => {
                  'id' => task.demand.company.id.to_s
                }
              }
            end
          )
        end
      end
    end
  end
end
