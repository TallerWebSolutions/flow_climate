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

    describe '#portfolio unit' do
      context 'with portfolio data' do
        it 'return portfolios data' do
          company = Fabricate :company
          product = Fabricate :product, id: 315, company: company
          second_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'xxx', id: 2086, product_id: 315, portfolio_unit_type: 1
          first_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'zzz', id: 2087, parent_id: second_portfolio_unit.id, product_id: 315, portfolio_unit_type: 1

          query =
            %(query {
            portfolioUnitById(id: #{first_portfolio_unit.id}) {
              id
              name
              totalCost
              totalHours
              portfolioUnitTypeName
              parent {
                id
                name
              }
            }
          })
          context = {
            current_portfolio: first_portfolio_unit
          }

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

          expect(result.dig('data', 'portfolioUnitById', 'name')).to eq('zzz')
        end
      end

      context 'without jira name data' do
        it 'returns empty' do
          company = Fabricate :company
          product = Fabricate :product, id: 315, company: company
          second_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'xxx', id: 2086, product_id: 315, portfolio_unit_type: 1
          first_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'zzz', id: 2087, parent_id: second_portfolio_unit.id, product_id: 315, portfolio_unit_type: 1

          query =
            %(query {
            jiraPortfolioUnitById(id: #{first_portfolio_unit.id})
          })
          context = {
            current_portfolio: first_portfolio_unit
          }

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

          expect(result.dig('data', 'jiraPortfolioUnitById')).to eq('')
        end
      end

      context 'with jira name data' do
        it 'returns jira name' do
          company = Fabricate :company
          product = Fabricate :product, id: 315, company: company
          second_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'xxx', id: 2086, product_id: 315, portfolio_unit_type: 1
          first_portfolio_unit = Fabricate :portfolio_unit, product: product, name: 'zzz', id: 2087, parent_id: second_portfolio_unit.id, product_id: 315, portfolio_unit_type: 1
          Fabricate :jira_portfolio_unit_config, id: 1, jira_field_name: 'bbb', portfolio_unit_id: 2087, portfolio_unit: first_portfolio_unit

          query =
            %(query {
            jiraPortfolioUnitById(id: #{first_portfolio_unit.id})
          })
          context = {
            current_portfolio: first_portfolio_unit
          }

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

          expect(result.dig('data', 'jiraPortfolioUnitById')).to eq('bbb')
        end
      end
    end

    describe '#team' do
      context 'with replenishing consolidations' do
        it 'returns the team and its fields' do
          travel_to Time.zone.local(2022, 9, 25, 10) do
            company = Fabricate :company
            team = Fabricate :team, company: company
            team_member = Fabricate :team_member, company: company, name: 'ddd', start_date: 4.months.ago, end_date: nil, monthly_payment: 2500.00, hours_per_month: 160
            other_team_member = Fabricate :team_member, company: company, name: 'aaa', start_date: 4.months.ago, end_date: nil, monthly_payment: 2000.00, hours_per_month: 160
            customer = Fabricate :customer, company: company
            product = Fabricate :product, company: company, customer: customer
            project = Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 4.days.ago, end_date: 1.day.from_now, max_work_in_progress: 2, hour_value: 180
            other_project = Fabricate :project, company: company, team: team, status: :executing, start_date: 2.days.ago, end_date: 4.days.from_now, max_work_in_progress: 4, hour_value: 163
            inactive_by_date_project = Fabricate :project, company: company, team: team, status: :executing, start_date: 2.days.ago, end_date: 1.day.ago
            inactive_by_status_project = Fabricate :project, company: company, team: team, status: :finished, start_date: 2.days.ago, end_date: 1.day.ago
            membership = Fabricate :membership, team: team, team_member: team_member, start_date: 6.days.ago, end_date: nil, hours_per_month: 160, member_role: :developer
            other_membership = Fabricate :membership, team: team, team_member: other_team_member, start_date: 6.days.ago, end_date: nil, hours_per_month: 160, member_role: :client
            demand = Fabricate :demand, product: product, customer: customer, project: project
            assignment = Fabricate :item_assignment, demand: demand, membership: membership
            Fabricate :demand_effort, demand: demand, item_assignment: assignment, effort_value: 100, start_time_to_computation: 1.month.ago
            Fabricate :demand_effort, demand: demand, item_assignment: assignment, effort_value: 120, start_time_to_computation: 2.months.ago

            Fabricate :replenishing_consolidation, project: project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6, team_based_montecarlo_80_percent: 0.5, team_monte_carlo_weeks_max: 9, team_monte_carlo_weeks_min: 2, team_monte_carlo_weeks_std_dev: 2.1, team_based_odds_to_deadline: 0.9
            replenishing_consolidation = Fabricate :replenishing_consolidation, project: project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6, team_based_montecarlo_80_percent: 0.2, team_monte_carlo_weeks_max: 7, team_monte_carlo_weeks_min: 4, team_monte_carlo_weeks_std_dev: 4.1, team_based_odds_to_deadline: 0.7

            Fabricate :replenishing_consolidation, project: other_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6, team_based_montecarlo_80_percent: 0.6, team_monte_carlo_weeks_max: 8, team_monte_carlo_weeks_min: 1, team_monte_carlo_weeks_std_dev: 4.1, team_based_odds_to_deadline: 0.5
            other_replenishing_consolidation = Fabricate :replenishing_consolidation, project: other_project, consolidation_date: Time.zone.today, team_throughput_data: [10, 9, 15], team_lead_time: 4.1, team_wip: 6

            Fabricate :replenishing_consolidation, project: inactive_by_date_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6
            Fabricate :replenishing_consolidation, project: inactive_by_status_project, consolidation_date: 1.day.ago, team_throughput_data: [7, 10, 9], team_lead_time: 2.4, team_wip: 6

            Fabricate :project_consolidation, project: project, consolidation_date: 3.days.ago, project_throughput: 7, project_throughput_hours_additional: 200, project_throughput_hours_additional_in_month: 240
            Fabricate :project_consolidation, project: project, consolidation_date: 2.days.ago, project_throughput: 10, project_throughput_hours_additional: 18, project_throughput_hours_additional_in_month: 32
            Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_throughput: 20, project_throughput_hours_additional: 2, project_throughput_hours_additional_in_month: 9

            Fabricate :project_consolidation, project: other_project, consolidation_date: 3.days.ago, project_throughput: 9, project_throughput_hours_additional: 22, project_throughput_hours_additional_in_month: 430
            Fabricate :project_consolidation, project: other_project, consolidation_date: 2.days.ago, project_throughput: 13, project_throughput_hours_additional: 17, project_throughput_hours_additional_in_month: 60
            Fabricate :project_consolidation, project: other_project, consolidation_date: 1.day.ago, project_throughput: 15, project_throughput_hours_additional: 47, project_throughput_hours_additional_in_month: 79

            service_delivery_review = Fabricate :service_delivery_review, company: company, product: product, id: 1, company_id: company.id, product_id: product.id, delayed_expedite_bottom_threshold: 1.0, delayed_expedite_top_threshold: 1.0, expedite_max_pull_time_sla: 1, lead_time_bottom_threshold: 1, lead_time_top_threshold: 1.0, quality_bottom_threshold: 1.0, quality_top_threshold: 1.0

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
              serviceDeliveryReviews(productId: #{product.id}) {
                id
                delayedExpediteBottomThreshold
                delayedExpediteTopThreshold
                expediteMaxPullTimeSla
                leadTimeBottomThreshold
                leadTimeTopThreshold
                qualityBottomThreshold
                qualityTopThreshold
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
                latestDeliveries { id }
                leadTimeP65
                leadTimeP80
                leadTimeP95
                numberOfDemandsDelivered
                cumulativeFlowChartData {
                  xAxis
                  yAxis {
                    name
                    data
                  }
                }
                demandsFlowChartData {
                  creationChartData
                  committedChartData
                  pullTransactionRate
                  throughputChartData
                  xAxis
                }
                leadTimeHistogramData {
                  keys
                  values
                }
                teamConsolidationsWeekly {
                  leadTimeP80
                  consolidationDate
                }
                teamMonthlyInvestment {
                  xAxis
                  yAxis
                }
                teamMemberEfficiency {
                  membersEfficiency {
                    membership {
                      teamMemberName
                    }
                    effortInMonth
                    realizedMoneyInMonth
                  }
                }
                membershipHourValueChartList(startDate: "#{1.month.ago.to_date.iso8601}") {
                  membership {
                    id
                  }
                  memberHourValueChartData {
                    date
                    hourValueExpected
                    hourValueRealized
                  }
                }
                memberships(active: true) {
                  id
                  memberRoleDescription
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
                    maxWorkInProgress
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
                      leadtimeEvolutionData {
                        xAxis
                      }
                    }
                  }
                }
              }
            })

            user = Fabricate :user, companies: [company], last_company_id: company.id

            context = { current_user: user }

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
            expect(result.dig('data', 'serviceDeliveryReviews')).to eq([{
                                                                         'id' => service_delivery_review.id.to_s,
                                                                         'delayedExpediteBottomThreshold' => 1.0,
                                                                         'delayedExpediteTopThreshold' => 1.0,
                                                                         'expediteMaxPullTimeSla' => 1,
                                                                         'leadTimeTopThreshold' => 1.0,
                                                                         'leadTimeBottomThreshold' => 1.0,
                                                                         'qualityBottomThreshold' => 1.0,
                                                                         'qualityTopThreshold' => 1.0
                                                                       }])
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
                                                       'cumulativeFlowChartData' => { 'xAxis' => ['2022-09-25'], 'yAxis' => [] },
                                                       'demandsFlowChartData' => { 'committedChartData' => nil, 'creationChartData' => nil, 'pullTransactionRate' => nil, 'throughputChartData' => nil, 'xAxis' => [] },
                                                       'latestDeliveries' => [],
                                                       'leadTimeHistogramData' => { 'keys' => [], 'values' => [] },
                                                       'leadTimeP65' => 0.0,
                                                       'leadTimeP80' => 0.0,
                                                       'leadTimeP95' => 0.0,
                                                       'numberOfDemandsDelivered' => 0,
                                                       'teamConsolidationsWeekly' => [],
                                                       'teamMonthlyInvestment' => { 'xAxis' => ['2022-09-30'], 'yAxis' => [-4500.0] },
                                                       'teamMemberEfficiency' => { 'membersEfficiency' => [{ 'effortInMonth' => 0.0, 'membership' => { 'teamMemberName' => 'aaa' }, 'realizedMoneyInMonth' => 0.0 }, { 'effortInMonth' => 0.0, 'membership' => { 'teamMemberName' => 'ddd' }, 'realizedMoneyInMonth' => 0.0 }] },
                                                       'membershipHourValueChartList' => [{ 'memberHourValueChartData' => [{ 'date' => '2022-08-31', 'hourValueExpected' => 15.625, 'hourValueRealized' => 25.0 }, { 'date' => '2022-09-30', 'hourValueExpected' => 15.625, 'hourValueRealized' => 0.0 }], 'membership' => { 'id' => membership.id.to_s } }, { 'memberHourValueChartData' => [{ 'date' => '2022-08-31', 'hourValueExpected' => 12.5, 'hourValueRealized' => 0.0 }, { 'date' => '2022-09-30', 'hourValueExpected' => 12.5, 'hourValueRealized' => 0.0 }], 'membership' => { 'id' => other_membership.id.to_s } }],
                                                       'memberships' => [{ 'id' => other_membership.id.to_s, 'memberRoleDescription' => 'Cliente' },
                                                                         { 'id' => membership.id.to_s, 'memberRoleDescription' => 'Desenvolvedor' }],
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
                                                             'maxWorkInProgress' => project.max_work_in_progress.to_i,
                                                             'weeklyThroughputs' => project.last_weekly_throughput,
                                                             'modeWeeklyTroughputs' => 3,
                                                             'stdDevWeeklyTroughputs' => 4.949747468305833,
                                                             'teamMonteCarloP80' => 0.2,
                                                             'teamMonteCarloWeeksMax' => 7.0,
                                                             'teamMonteCarloWeeksMin' => 4.0,
                                                             'teamMonteCarloWeeksStdDev' => 4.1,
                                                             'teamBasedOddsToDeadline' => 0.7,
                                                             'customers' => [{ 'name' => customer.name }],
                                                             'products' => [{ 'name' => product.name, 'leadtimeEvolutionData' => { 'xAxis' => ['2022-09-30'] } }]
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
                                                             'flowPressurePercentage' => other_project.relative_flow_pressure_in_replenishing_consolidation.to_f,
                                                             'qtySelected' => other_project.qty_selected_in_week,
                                                             'leadTimeP80' => other_project.general_leadtime.to_f,
                                                             'qtyInProgress' => other_project.in_wip.count,
                                                             'monteCarloP80' => other_project.monte_carlo_p80.to_f,
                                                             'maxWorkInProgress' => other_project.max_work_in_progress.to_i,
                                                             'weeklyThroughputs' => other_project.last_weekly_throughput,
                                                             'modeWeeklyTroughputs' => 4,
                                                             'stdDevWeeklyTroughputs' => 1.4142135623730951,
                                                             'teamMonteCarloP80' => 10.1,
                                                             'teamMonteCarloWeeksMax' => 20.0,
                                                             'teamMonteCarloWeeksMin' => 4.0,
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

  describe '#project' do
    context 'with project' do
      it 'returns the project and its fields' do
        travel_to Time.zone.local(2022, 4, 30, 10, 0, 0) do
          company = Fabricate :company

          bug_type = Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true

          team = Fabricate :team, company: company
          customer = Fabricate :customer, company: company
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, company: company, customers: [customer], products: [product], team: team, name: 'zzz', initial_scope: 20,
                                        status: :executing, start_date: 31.days.ago, end_date: 1.day.from_now, max_work_in_progress: 2, qty_hours: 500
          other_project = Fabricate :project, company: company, customers: [customer], products: [product], team: team, name: 'aaa', initial_scope: 20,
                                              status: :executing, start_date: 31.days.ago, end_date: 1.day.from_now, max_work_in_progress: 2, qty_hours: 500

          Fabricate :demand, company: company, project: project, team: team

          first_finished_demand = Fabricate :demand, project: project, effort_downstream: 200, effort_upstream: 10, end_date: Time.zone.local(2022, 4, 24, 12, 30)
          second_finished_demand = Fabricate :demand, project: project, work_item_type: bug_type, created_date: Time.zone.local(2022, 4, 2, 13, 30), commitment_date: Time.zone.local(2022, 4, 3, 10, 30), end_date: Time.zone.local(2022, 4, 5, 17, 30), effort_downstream: 15, effort_upstream: 30

          project_consolidation = Fabricate :project_consolidation, project: project, consolidation_date: 1.month.ago, last_data_in_week: true, monte_carlo_weeks_min: 3, monte_carlo_weeks_max: 20, monte_carlo_weeks_std_dev: 8, team_based_operational_risk: 2.5, project_throughput_hours_additional: 14, project_throughput_hours_additional_in_month: 100, project_throughput_hours: 20, project_scope_hours: 200, project_scope: 41, project_throughput: 20
          other_project_consolidation = Fabricate :project_consolidation, project: project, consolidation_date: Time.zone.local(2022, 4, 24), last_data_in_week: true, monte_carlo_weeks_min: 9, monte_carlo_weeks_max: 85, monte_carlo_weeks_std_dev: 7, team_based_operational_risk: 0.5, project_throughput_hours_additional: 17, project_throughput_hours_additional_in_month: 60, project_throughput_hours: 30, project_scope_hours: 250, project_scope: 61, project_throughput: 10

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

                currentCompany {
                  projects {
                    id
                  }
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
                quality
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
                  leadTimeP75
                  projectThroughputHoursAdditional
                  projectThroughputHoursAdditionalInMonth
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
                leadTimeBreakdown {
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
                demandsBurnup {
                  xAxis
                  idealBurn
                  currentBurn
                  scope
                }
                hoursBurnup {
                  xAxis
                  idealBurn
                  currentBurn
                  scope
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

          user = Fabricate :user, last_company: company

          context = {
            current_user: user
          }

          cfd_doubled = [['Bla', [1, 2, 3]], ['Xpto', [3, 2, 1]]]

          allow_any_instance_of(Flow::WorkItemFlowInformation).to(receive(:demands_stages_count_hash)).and_return(cfd_doubled)

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
          expect(result.dig('data', 'me')).to eq({
                                                   'id' => user.id.to_s,
                                                   'fullName' => user.full_name,
                                                   'companies' => [],
                                                   'currentCompany' => {
                                                     'projects' => [
                                                       {
                                                         'id' => other_project.id.to_s
                                                       },
                                                       {
                                                         'id' => project.id.to_s
                                                       }
                                                     ]
                                                   },
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
                                                        'quality' => project.quality,
                                                        'pastWeeks' => project.past_weeks.to_i,
                                                        'currentWeeksByLittleLaw' => 0,
                                                        'currentMonteCarloWeeksMin' => 9,
                                                        'currentMonteCarloWeeksMax' => 85,
                                                        'currentMonteCarloWeeksStdDev' => 7,
                                                        'remainingWork' => 18,
                                                        'currentTeamBasedRisk' => 0.5,
                                                        'currentRiskToDeadline' => 0.0,
                                                        'remainingDays' => project.remaining_days,
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
                                                          'leadTimeP75' => project_consolidation.lead_time_p75,
                                                          'projectThroughputHoursAdditional' => project_consolidation.project_throughput_hours_additional,
                                                          'projectThroughputHoursAdditionalInMonth' => project_consolidation.project_throughput_hours_additional_in_month
                                                        }, {
                                                          'id' => other_project_consolidation.id.to_s,
                                                          'interquartileRange' => 0.0,
                                                          'leadTimeHistogramBinMax' => 0.0,
                                                          'leadTimeHistogramBinMin' => 0.0,
                                                          'leadTimeMaxMonth' => 0.0,
                                                          'leadTimeMinMonth' => 0.0,
                                                          'leadTimeP25' => other_project_consolidation.lead_time_p65,
                                                          'leadTimeP75' => other_project_consolidation.lead_time_p75,
                                                          'projectThroughputHoursAdditional' => other_project_consolidation.project_throughput_hours_additional,
                                                          'projectThroughputHoursAdditionalInMonth' => other_project_consolidation.project_throughput_hours_additional_in_month
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
                                                        'leadTimeBreakdown' => {
                                                          'xAxis' => [],
                                                          'yAxis' => []
                                                        },
                                                        'projectConsolidationsWeekly' => [{ 'id' => project_consolidation.id.to_s }, { 'id' => other_project_consolidation.id.to_s }],
                                                        'projectConsolidationsLastMonth' => [],
                                                        'lastProjectConsolidationsWeekly' => { 'id' => other_project_consolidation.id.to_s },
                                                        'demandsFlowChartData' => { 'committedChartData' => [0, 0, 0, 0, 0], 'creationChartData' => [1, 0, 0, 0, 3], 'pullTransactionRate' => [0, 0, 0, 0, 0], 'throughputChartData' => [0, 1, 0, 1, 0] },
                                                        'cumulativeFlowChartData' => { 'xAxis' => %w[2022-04-03 2022-04-10 2022-04-17 2022-04-24 2022-05-01], 'yAxis' => [{ 'data' => [1, 2, 3], 'name' => 'Bla' }, { 'data' => [3, 2, 1], 'name' => 'Xpto' }] },
                                                        'leadTimeHistogramData' => {
                                                          'keys' => [198_000.0],
                                                          'values' => [1]
                                                        },
                                                        'projectMembers' => [{
                                                          'demandsCount' => 2,
                                                          'memberName' => 'foo'
                                                        }],
                                                        'demandsBurnup' => {
                                                          'xAxis' => TimeService.instance.weeks_between_of(project.start_date, project.end_date).map(&:iso8601),
                                                          'idealBurn' => [12.2, 24.4, 36.599999999999994, 48.8, 61.0],
                                                          'currentBurn' => [20, 10],
                                                          'scope' => [41, 61, 61, 61, 61]
                                                        },
                                                        'hoursBurnup' => {
                                                          'xAxis' => TimeService.instance.weeks_between_of(project.start_date, project.end_date).map(&:iso8601),
                                                          'idealBurn' => [100.0, 200.0, 300.0, 400.0, 500.0],
                                                          'currentBurn' => [20, 30],
                                                          'scope' => [200, 250, 250, 250, 250]
                                                        }
                                                      })

          expect(result.dig('data', 'projectConsolidations')).to match_array([{
                                                                               'id' => project_consolidation.id.to_s,
                                                                               'interquartileRange' => 0.0,
                                                                               'leadTimeHistogramBinMax' => 0.0,
                                                                               'leadTimeHistogramBinMin' => 0.0,
                                                                               'leadTimeMaxMonth' => 0.0,
                                                                               'leadTimeMinMonth' => 0.0,
                                                                               'leadTimeP25' => 0.0,
                                                                               'leadTimeP75' => 0.0
                                                                             }, {
                                                                               'id' => other_project_consolidation.id.to_s,
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

    context 'with project simulation' do
      it 'returns the project simulation given the constraints' do
        team = Fabricate :team, max_work_in_progress: 2
        project = Fabricate :project, team: team
        remaining_work = 100
        throughputs = [5, 10, 15, 20, 10]

        query =
          %(query {
            project(id: #{project.id}) {
              id
              projectSimulation(remainingWork: #{remaining_work}, throughputs: #{throughputs}, endDate: "2022-12-31") {
                operationalRisk
                teamOperationalRisk
                monteCarloP80
                currentMonteCarloWeeksMax
                currentMonteCarloWeeksMin
                currentMonteCarloWeeksStdDev
                teamMonteCarloP80
                teamMonteCarloWeeksMax
                teamMonteCarloWeeksMin
                teamMonteCarloWeeksStdDev
              }
            }
          })

        expect(Stats::StatisticsService.instance).to(receive(:run_montecarlo)).once.with(remaining_work, [12.5, 25.0, 37.5, 50.0, 25.0], 500).and_return([])
        expect(Stats::StatisticsService.instance).to(receive(:run_montecarlo)).once.with(remaining_work, throughputs, 500).and_return([])

        FlowClimateSchema.execute(query, variables: nil, context: nil).as_json
      end
    end
  end

  describe '#product' do
    context 'with valid' do
      it 'returns the product using the slug informed' do
        travel_to Time.zone.local(2022, 12, 7, 10) do
          company = Fabricate :company

          customer = Fabricate :customer, company: company
          product = Fabricate :product, company: company, customer: customer
          unit = Fabricate :portfolio_unit, product: product, name: 'zzz', parent: nil, portfolio_unit_type: :theme
          other_unit = Fabricate :portfolio_unit, product: product, parent: unit, portfolio_unit_type: :epic
          another_unit = Fabricate :portfolio_unit, product: product, parent: nil, name: 'aaa', portfolio_unit_type: :theme

          user = Fabricate :user, last_company: company, first_name: 'zzz'

          first_user = Fabricate :user
          second_user = Fabricate :user

          product.users << first_user
          product.users << second_user

          first_outside = Fabricate :user, first_name: 'aaa', last_name: 'bbb'
          second_outside = Fabricate :user, first_name: 'aaa', last_name: 'aaa'
          third_outside = Fabricate :user, first_name: 'bbb', last_name: 'aaa'

          graphql_context = {
            current_user: user
          }

          query =
            %(
              query ProductQuery {
                product(slug: "#{product.slug}") {
                  id
                  name
                  slug
                  createdDemandsCount
                  deliveredDemandsCount
                  remainingBacklogCount
                  upstreamDemandsCount
                  downstreamDemandsCount
                  discardedDemandsCount
                  unscoredDemandsCount
                  demandsBlocksCount
                  portfolioUnitsCount
                  averageSpeed
                  averageQueueTime
                  averageTouchTime
                  leadtimeP95
                  leadtimeP80
                  leadtimeP65
                  usersCount

                  usersOutside {
                    id
                  }

                  memberships{
                    id
                    teamMemberName
                  }

                  latestDeliveries {
                    id
                    customerName
                    productName
                    endDate
                    leadtime
                    demandBlocksCount
                  }

                  leadtimeEvolutionData {
                    xAxis
                    yAxisInMonth
                    yAxisAccumulated
                  }

                  portfolioUnits {
                    id
                    portfolioUnitTypeName
                  }

                  company {
                    id
                    name
                    slug
                  }
                }
              }
            )

          expect(Demand).to(receive(:unscored_demands)).once.and_return(Demand.all)
          expect(Demand).to(receive(:in_wip)).once.and_return(Demand.all)
          expect(Demand).to(receive(:discarded)).once.and_return(Demand.all)
          expect(Demand).to(receive(:finished_until_date)).once.and_return(Demand.all)
          expect(Demand).to(receive(:opened_before_date)).once.and_return(Demand.all)
          expect_any_instance_of(Product).to(receive(:upstream_demands)).once.and_return(Demand.all)
          expect_any_instance_of(Product).to(receive(:demand_blocks)).once.and_return(DemandBlock.all)
          expect(DemandService.instance).to(receive(:average_speed)).once
          expect_any_instance_of(Product).to(receive(:general_leadtime).with(95)).once
          expect_any_instance_of(Product).to(receive(:general_leadtime).with(no_args)).once
          expect_any_instance_of(Product).to(receive(:general_leadtime).with(65)).once
          expect_any_instance_of(Highchart::DemandsChartsAdapter).to(receive(:leadtime_percentiles_on_time_chart_data)).once.and_call_original

          result = FlowClimateSchema.execute(query, variables: nil, context: graphql_context).as_json

          expect(result.dig('data', 'product')['id']).to eq product.id.to_s
          expect(result.dig('data', 'product')['portfolioUnitsCount']).to eq 3
          expect(result.dig('data', 'product')['portfolioUnits'].pluck('id')).to eq [another_unit.id.to_s, unit.id.to_s, other_unit.id.to_s]
          expect(result.dig('data', 'product')['usersCount']).to eq 2
          expect(result.dig('data', 'product')['usersOutside'].pluck('id')).to eq([second_outside, first_outside, third_outside, user].map { |u| u.id.to_s })
          expect(result.dig('data', 'product')['portfolioUnits'].pluck('portfolioUnitTypeName')).to eq %w[Tema Tema Épico]
        end
      end
    end

    context 'with an inexistent product' do
      it 'returns 404' do
        company = Fabricate :company

        user = Fabricate :user, last_company: company

        graphql_context = {
          current_user: user
        }

        query =
          %(
          query ProductQuery {
            product(slug: "foo") {
              id
            }
          }
        )

        expect { FlowClimateSchema.execute(query, variables: nil, context: graphql_context) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#service_delivery_review' do
    it 'brings the data of a sdr given an ID' do
      travel_to Time.zone.local(2023, 5, 3, 10) do
        product = Fabricate :product
        review = Fabricate :service_delivery_review, product: product, meeting_date: Time.zone.now
        Fabricate :service_delivery_review, product: product, meeting_date: 5.weeks.ago

        query =
          %(
            query {
              serviceDeliveryReview(reviewId: "#{review.id}") {
                id
                bugsCount
                demandsCount
                discardedCount
                longestStage {
                  id
                }
                flowEventsChartData {
                  label
                  value
                }
                classOfServiceChartData {
                  label
                  value
                }
              }
            }
          )

        project = Fabricate :project, products: [product]
        Fabricate :flow_event, project: project, event_date: 2.days.ago, event_type: :other_team_dependency
        Fabricate :flow_event, project: project, event_date: 1.week.ago, event_type: :api_not_ready
        Fabricate :flow_event, project: project, event_date: 2.days.from_now, event_type: :customer_not_available

        Fabricate :demand, project: project, company: project.company, service_delivery_review: review, end_date: 4.weeks.ago, class_of_service: :expedite
        Fabricate :demand, project: project, company: project.company, service_delivery_review: review, end_date: 3.weeks.ago, class_of_service: :standard
        Fabricate :demand, project: project, company: project.company, service_delivery_review: review, end_date: 2.weeks.ago, class_of_service: :standard
        Fabricate :demand, project: project, company: project.company, service_delivery_review: review, end_date: 4.days.ago, class_of_service: :fixed_date

        review.save

        result = FlowClimateSchema.execute(query, variables: nil).as_json

        expect(result.dig('data', 'serviceDeliveryReview', 'id')).to eq review.id.to_s
        expect(result.dig('data', 'serviceDeliveryReview', 'flowEventsChartData').pluck('label')).to contain_exactly('Dependência de outro time', 'API não está pronta')
        expect(result.dig('data', 'serviceDeliveryReview', 'classOfServiceChartData').pluck('label')).to eq(['Padrão', 'Expedição', 'Data Fixa'])
      end
    end
  end

  describe '#demands_list' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }
    let(:project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 10.days.ago, end_date: 5.days.from_now, max_work_in_progress: 4 }
    let(:other_project) { Fabricate :project, company: company, customers: [customer], products: [product], team: team, status: :executing, start_date: 10.days.ago, end_date: 5.days.from_now, max_work_in_progress: 4 }

    context 'with project id' do
      it 'returns the demands' do
        demand = Fabricate :demand, company: company, project: project, team: team, end_date: 1.day.ago
        Fabricate :demand_block, demand: demand
        Fabricate :demand, company: company, project: other_project, team: team
        Fabricate :demand_effort, demand: demand, effort_value: 90

        query =
          %(
            query {
              demandsList(searchOptions: { projectId: #{project.id}, perPage: 1, demandStatus: DELIVERED_DEMANDS, orderField: "end_date" }) {
                demands {
                  demandBlocksCount
                  responsibles { id }
                }
                totalEffort
              }
            }
          )

        user = Fabricate :user, last_company_id: company.id
        context = { current_user: user }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'demandsList')).to eq({ 'demands' => [{ 'demandBlocksCount' => 1, 'responsibles' => [] }], 'totalEffort' => 90 })
      end
    end

    context 'with no project id' do
      it 'returns the demands in the company' do
        travel_to Time.zone.local(2022, 6, 7, 10, 0, 0) do
          Fabricate :demand, company: company, project: project, team: team, end_date: 2.days.ago
          Fabricate :demand, company: company, project: other_project, team: team, end_date: 1.day.ago

          Fabricate :demand, company: company, project: project, team: team, created_date: 3.days.ago, commitment_date: 3.days.ago, end_date: 2.days.ago, total_queue_time: 100_000, total_touch_time: 3763
          Fabricate :demand, company: company, project: project, team: team, created_date: 4.days.ago, commitment_date: 4.days.ago, end_date: 3.days.ago, total_queue_time: 100_000, total_touch_time: 23_212
          Fabricate :demand, company: company, project: project, team: team, created_date: 5.days.ago, commitment_date: 5.days.ago, end_date: 4.days.ago, total_queue_time: 100_000, total_touch_time: 939_382
          Fabricate :demand, company: company, project: project, team: team, created_date: 2.days.ago, commitment_date: 2.days.ago, end_date: 1.day.ago, total_queue_time: 100_000, total_touch_time: 12_234
          Fabricate :demand, company: company, project: project, team: team, created_date: 7.days.ago, commitment_date: 7.days.ago, end_date: 5.days.ago, total_queue_time: 100_000, total_touch_time: 3768

          demands_external_ids = Demand.finished_with_leadtime.order(end_date: :asc).map(&:external_id)
          demands_lead_times = Demand.finished_with_leadtime.order(end_date: :asc).map { |demand| demand.leadtime.to_f }
          demands_ids = Demand.order(:created_date).map(&:id)

          lead_time_p65 = Stats::StatisticsService.instance.percentile(65, demands_lead_times)
          lead_time_p80 = Stats::StatisticsService.instance.percentile(80, demands_lead_times)
          lead_time_p95 = Stats::StatisticsService.instance.percentile(95, demands_lead_times)

          query =
            %(
              query {
                demandsList(searchOptions: { perPage: 20, demandStatus: DELIVERED_DEMANDS, orderField: "end_date" }) {
                  totalCount
                  demands {
                    id
                  }
                  controlChart {
                    leadTimeP65
                    leadTimeP80
                    leadTimeP95

                    leadTimes
                    xAxis
                  }
                  leadTimeBreakdown {
                    xAxis
                    yAxis
                  }
                  flowData {
                    xAxis
                    creationChartData
                    committedChartData
                    pullTransactionRate
                    throughputChartData
                  }
                  flowEfficiency {
                    xAxis
                    yAxis
                  }
                  leadTimeEvolutionP80 {
                    xAxis
                    yAxis
                  }
                }
              }
            )

          user = Fabricate :user, last_company_id: company.id
          context = { current_user: user }

          result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
          expect(result.dig('data', 'demandsList', 'totalCount')).to eq 7
          expect(result.dig('data', 'demandsList', 'demands')).to match_array(demands_ids.map { |id| { 'id' => id.to_s } })
          expect(result.dig('data', 'demandsList', 'controlChart', 'leadTimeP65')).to be_within(0.1).of lead_time_p65
          expect(result.dig('data', 'demandsList', 'controlChart', 'leadTimeP80')).to be_within(0.1).of lead_time_p80
          expect(result.dig('data', 'demandsList', 'controlChart', 'leadTimeP95')).to be_within(0.1).of lead_time_p95
          expect(result.dig('data', 'demandsList', 'controlChart', 'xAxis')).to eq demands_external_ids
          expect(result.dig('data', 'demandsList', 'controlChart', 'leadTimes')).to eq demands_lead_times
          expect(result.dig('data', 'demandsList', 'leadTimeBreakdown', 'xAxis')).to eq []
          expect(result.dig('data', 'demandsList', 'leadTimeBreakdown', 'yAxis')).to eq []
          expect(result.dig('data', 'demandsList', 'flowData', 'xAxis')).to eq %w[2022-04-17 2022-04-24 2022-05-01 2022-05-08 2022-05-15 2022-05-22 2022-05-29 2022-06-05 2022-06-12]
          expect(result.dig('data', 'demandsList', 'flowData', 'creationChartData')).to eq [0, 0, 0, 0, 0, 0, 0, 6, 0]
          expect(result.dig('data', 'demandsList', 'flowData', 'committedChartData')).to eq [0, 0, 0, 0, 0, 0, 0, 4, 0]
          expect(result.dig('data', 'demandsList', 'flowData', 'pullTransactionRate')).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0]
          expect(result.dig('data', 'demandsList', 'flowData', 'throughputChartData')).to eq [0, 0, 0, 0, 0, 0, 0, 5, 2]
          expect(result.dig('data', 'demandsList', 'flowEfficiency', 'xAxis')).to eq %w[2022-04-17 2022-04-24 2022-05-01 2022-05-08 2022-05-15 2022-05-22 2022-05-29 2022-06-05 2022-06-12]
          expect(result.dig('data', 'demandsList', 'flowEfficiency', 'yAxis')).to eq [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 76.31009142725382, 66.2699791346091]
          expect(result.dig('data', 'demandsList', 'leadTimeEvolutionP80', 'xAxis')).to eq %w[2022-04-17 2022-04-24 2022-05-01 2022-05-08 2022-05-15 2022-05-22 2022-05-29 2022-06-05 2022-06-12]
          expect(result.dig('data', 'demandsList', 'leadTimeEvolutionP80', 'yAxis')).to eq [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 138_240.0, 103_680.00000000001]
        end
      end
    end

    context 'with no pagination' do
      it 'returns the demands in the company with no pagination' do
        demand = Fabricate :demand, company: company, project: project, team: team, end_date: 2.days.ago
        other_demand = Fabricate :demand, company: company, project: other_project, team: team, end_date: 1.day.ago

        query =
          %(
        query {
          demandsList(searchOptions: { demandStatus: DELIVERED_DEMANDS, orderField: "end_date" }) {
            totalCount
            demands {
              id
              demandType
            }
          }
        }
      )

        user = Fabricate :user, last_company_id: company.id

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'demandsList', 'totalCount')).to eq 2
        expect(result.dig('data', 'demandsList', 'demands')[0]).to eq({ 'id' => other_demand.id.to_s, 'demandType' => other_demand.demand_type })
        expect(result.dig('data', 'demandsList', 'demands')[1]).to eq({ 'id' => demand.id.to_s, 'demandType' => demand.demand_type })
      end
    end
  end

  describe '#demand' do
    context 'with valid ID' do
      it 'returns the demand' do
        now = DateTime.current
        demand = Fabricate :demand
        demand_effort = Fabricate :demand_effort, demand: demand, start_time_to_computation: now - 1.hour
        other_demand_effort = Fabricate :demand_effort, demand: demand, start_time_to_computation: now - 2.hours

        query =
          %(
          query {
            demand(externalId: "#{demand.external_id}") {
              id
              demandEfforts {
                id
              }
              itemAssignments {
                id
              }
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'demand')['id']).to eq demand.id.to_s
        expect(result.dig('data', 'demand', 'demandEfforts')).to eq [{ 'id' => other_demand_effort.id.to_s }, { 'id' => demand_effort.id.to_s }]
      end
    end

    context 'with invalid ID' do
      it 'returns nil' do
        query =
          %(
          query {
            demand(externalId: "foo") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'demand')).to be_nil
      end
    end
  end

  describe '#risk_Review' do
    context 'with valid ID' do
      it 'returns the risk review' do
        risk_review = Fabricate :risk_review

        query =
          %(
          query {
            riskReview(id: "#{risk_review.id}") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'riskReview', 'id')).to eq risk_review.id.to_s
      end
    end

    context 'with invalid ID' do
      it 'returns nil' do
        query =
          %(
          query {
            risk_review(id: "foo") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'risk_review')).to be_nil
      end
    end
  end

  describe '#projects' do
    let(:company) { Fabricate :company }

    let(:query) do
      %(query {
        projects(companyId: #{company.id}, name: "foo,xpto", status: "waiting") {
          id
          name
          team {
            id
            name
          }
          status
          numberOfDemands
          remainingDays
          numberOfDemandsDelivered
          qtyHours
          consumedHours
          currentRiskToDeadline
        }
      })
    end

    context 'when project list' do
      it 'returns projects' do
        user = Fabricate :user

        context = {
          current_user: user
        }

        first_project = Fabricate :project, company: company, end_date: 5.days.ago, name: 'foo', status: 'waiting', start_date: 10.days.ago
        second_project = Fabricate :project, company: company, end_date: 6.days.ago, name: 'xpto', status: 'waiting', start_date: 15.days.ago
        Fabricate :project, company: company, end_date: 5.days.ago, name: 'bar', status: 'executing', start_date: 10.days.ago

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
        expect(result.dig('data', 'projects')).to eq([{
                                                       'id' => first_project.id.to_s,
                                                       'name' => first_project.name,
                                                       'team' => {
                                                         'id' => first_project.team.id.to_s,
                                                         'name' => first_project.team.name
                                                       },
                                                       'status' => first_project.status,
                                                       'numberOfDemands' => first_project.demands.kept.count,
                                                       'remainingDays' => first_project.remaining_days,
                                                       'numberOfDemandsDelivered' => first_project.demands.kept.finished_until_date(Time.zone.now).count,
                                                       'qtyHours' => first_project.qty_hours,
                                                       'consumedHours' => first_project.consumed_hours,
                                                       'currentRiskToDeadline' => first_project.current_risk_to_deadline
                                                     },
                                                      {
                                                        'id' => second_project.id.to_s,
                                                        'name' => second_project.name,
                                                        'team' => {
                                                          'id' => second_project.team.id.to_s,
                                                          'name' => second_project.team.name
                                                        },
                                                        'status' => second_project.status,
                                                        'numberOfDemands' => second_project.demands.kept.count,
                                                        'remainingDays' => second_project.remaining_days,
                                                        'numberOfDemandsDelivered' => second_project.demands.kept.finished_until_date(Time.zone.now).count,
                                                        'qtyHours' => second_project.qty_hours,
                                                        'consumedHours' => second_project.consumed_hours,
                                                        'currentRiskToDeadline' => second_project.current_risk_to_deadline
                                                      }])
      end
    end
  end

  describe '#team_members' do
    let(:company) { Fabricate :company }

    it 'returns the members in the company' do
      query =
        %(
        query {
          teamMembers(companyId: #{company.id}) {
            name
            jiraAccountUserEmail
            startDate
            endDate
            billable
            teams {
              name
            }
            user {
              firstName
              lastName
            }
          }
        }
      )

      user = Fabricate :user

      context = {
        current_user: user
      }

      team_member = Fabricate :team_member, company: company, name: 'zzz'
      other_team_member = Fabricate :team_member, company: company, name: 'aaa'

      team = Fabricate :team, company: company, name: 'xpto'
      other_team = Fabricate :team, company: company, name: 'foo'

      Fabricate :membership, team: team, team_member: team_member
      Fabricate :membership, team: other_team, team_member: team_member
      Fabricate :membership, team: team, team_member: other_team_member

      Fabricate :team_member, name: 'aaa'

      result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
      expect(result.dig('data', 'teamMembers').pluck('name')).to eq %w[aaa zzz]
      expect(result.dig('data', 'teamMembers').first['teams'].pluck('name')).to eq ['xpto']
      expect(result.dig('data', 'teamMembers').second['teams'].pluck('name')).to match_array %w[xpto foo]
    end

    it 'returns active members in the company' do
      query =
        %(
        query {
          teamMembers(companyId: #{company.id}, active: true) {
            name
            jiraAccountUserEmail
            startDate
            endDate
            billable
            teams {
              name
            }
            user {
              firstName
              lastName
            }
          }
        }
      )

      user = Fabricate :user

      context = {
        current_user: user
      }

      team_member = Fabricate :team_member, company: company, name: 'zzz', end_date: 1.day.ago
      other_team_member = Fabricate :team_member, company: company, name: 'aaa', end_date: nil

      team = Fabricate :team, company: company, name: 'xpto'

      Fabricate :membership, team: team, team_member: team_member
      Fabricate :membership, team: team, team_member: other_team_member

      result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
      expect(result.dig('data', 'teamMembers').pluck('name')).to eq %w[aaa]
    end

    it 'returns inactive members in the company' do
      query =
        %(
        query {
          teamMembers(companyId: #{company.id}, active: false) {
            name
            jiraAccountUserEmail
            startDate
            endDate
            billable
            teams {
              name
            }
            user {
              firstName
              lastName
            }
          }
        }
      )

      user = Fabricate :user

      context = {
        current_user: user
      }

      team_member = Fabricate :team_member, company: company, name: 'zzz', end_date: nil
      other_team_member = Fabricate :team_member, company: company, name: 'aaa', end_date: 7.days.ago

      team = Fabricate :team, company: company, name: 'xpto'

      Fabricate :membership, team: team, team_member: team_member
      Fabricate :membership, team: team, team_member: other_team_member

      result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
      expect(result.dig('data', 'teamMembers').pluck('name')).to eq %w[aaa]
    end
  end

  describe '#team_member' do
    it 'returns the team member and its fields' do
      travel_to(Time.zone.local(2022, 5, 18, 10, 0, 0)) do
        company = Fabricate :company
        feature_type = Fabricate :work_item_type, company: company, name: 'Feature'
        bug_type = Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true

        project = Fabricate :project, start_date: 2.weeks.ago, end_date: 1.day.from_now
        other_project = Fabricate :project, start_date: 2.weeks.ago, end_date: 2.days.from_now

        team = Fabricate :team, company: company
        other_team = Fabricate :team, company: company
        team_member = Fabricate :team_member, company: company, monthly_payment: 1000, hours_per_month: 160
        another_team_member = Fabricate :team_member, company: company, monthly_payment: 1000
        membership = Fabricate :membership, team_member: team_member, team: team, end_date: nil, hours_per_month: 100
        another_membership = Fabricate :membership, team_member: team_member, team: other_team, end_date: nil, hours_per_month: 60
        demand_finished = Fabricate :demand, team: team, project: project, created_date: 2.days.ago, commitment_date: 10.hours.ago, end_date: 1.hour.ago, work_item_type: feature_type
        other_demand_finished = Fabricate :demand, team: team, project: other_project, created_date: 3.days.ago, commitment_date: 6.hours.ago, end_date: 2.hours.ago, work_item_type: bug_type
        bug = Fabricate :demand, team: team, project: project, created_date: 2.days.ago, end_date: nil, work_item_type: bug_type
        other_bug = Fabricate :demand, team: team, project: project, created_date: 1.day.ago, end_date: nil, work_item_type: bug_type

        first_assignment = Fabricate :item_assignment, membership: membership, demand: demand_finished

        another_team_member_assignmen_that_should_not_appear = Fabricate :item_assignment, membership: another_membership, demand: demand_finished

        Fabricate :item_assignment, membership: membership, demand: other_demand_finished
        Fabricate :item_assignment, membership: membership, demand: bug
        Fabricate :item_assignment, membership: membership, demand: other_bug

        demand_block = Fabricate :demand_block, blocker: team_member, block_time: 1.day.ago
        other_demand_block = Fabricate :demand_block, blocker: team_member, block_time: 2.days.ago
        Fabricate :demand_block, blocker: another_team_member, block_time: 2.days.ago

        Dashboards::OperationsDashboard.create(team_member: team_member, dashboard_date: 2.months.ago, last_data_in_month: true, member_effort: 67.8, pull_interval: 200)
        Dashboards::OperationsDashboard.create(team_member: team_member, dashboard_date: 1.month.ago, last_data_in_month: true, member_effort: 12.3, pull_interval: 10)
        Dashboards::OperationsDashboard.create(team_member: team_member, dashboard_date: Time.zone.today, last_data_in_month: true, member_effort: 100, pull_interval: 89)

        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 2.days.ago, effort_value: 100
        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 2.days.ago, effort_value: 50

        Fabricate :demand_effort, demand: demand_finished, item_assignment: another_team_member_assignmen_that_should_not_appear, start_time_to_computation: 2.days.ago, effort_value: 10_000

        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 21.days.ago, finish_time_to_computation: 15.days.ago, effort_value: 100
        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 1.day.ago, effort_value: 20
        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 2.days.from_now, effort_value: 100
        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 2.days.from_now, effort_value: 70
        Fabricate :demand_effort, demand: demand_finished, item_assignment: first_assignment, start_time_to_computation: 2.months.ago, effort_value: 100

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
          teamMember(id: #{team_member.id}) {
            id
            name
            startDate
            endDate
            jiraAccountUserEmail
            jiraAccountId
            billable
            hoursPerMonth
            monthlyPayment
            teams {
              name
            }
            projectsEndDateAsc: projectsList(orderField: "end_date", sortDirection: ASC, perPage: 1) {
              totalCount
              lastPage
              totalPages
              projects {
                id
              }
            }
            projectsEndDateDesc: projectsList(orderField: "end_date", sortDirection: DESC, perPage: 1) {
              totalCount
              lastPage
              totalPages
              projects {
                id
              }
            }
            demandsFinished: demands(status: DELIVERED_DEMANDS) {
              id
            }
            bugs: demands(type: "BUG") {
              id
            }
            bugsFinished: demands(status: DELIVERED_DEMANDS, type: "BUG") {
              id
            }
            lastDeliveries: demands(status: DELIVERED_DEMANDS, limit: 1) {
              id
            }
            demandShortestLeadTime {
              id
            }
            demandLargestLeadTime {
              id
            }
            demandLeadTimeP80
            firstDelivery {
              id
            }
            demandBlocksListDesc: demandBlocksList(orderField: "block_time", sortDirection: DESC, perPage: 1) {
              totalPages
              lastPage
              totalCount
              demandBlocks {
                id
              }
            }
            demandBlocksListAsc: demandBlocksList(orderField: "block_time", sortDirection: ASC, perPage: 1) {
              totalPages
              lastPage
              totalCount
              demandBlocks {
                id
              }
            }
            leadTimeControlChartData {
              xAxis
              leadTimes
              leadTimeP65
              leadTimeP80
              leadTimeP95
            }
            leadTimeHistogramChartData {
              keys
              values
            }
            memberEffortData {
              xAxis
              yAxis
            }
            memberEffortDailyData {
              xAxis
              yAxis
            }
            averagePullIntervalData {
              xAxis
              yAxis
            }
            demandEfforts(fromDate: "#{25.days.ago.iso8601}", untilDate: "#{15.days.ago.iso8601}", pageNumber: 1){
              finishTimeToComputation
            }
            demandEffortsList(fromDate: "#{25.days.ago.iso8601}", untilDate: "#{15.days.ago.iso8601}", pageNumber: 1){
              demandEffortsCount
            }
            projectHoursData {
              xAxis
              yAxisProjectsNames
              yAxisHours
            }
            memberThroughputData(numberOfWeeks: 3)

            teamMemberHourValueChartList(startDate: "#{1.month.ago.to_date.iso8601}") {
              team {
                id
                name
              }
              memberHourValueChartData {
                date
                hourValueRealized
              }
            }
          }
        })

        user = Fabricate :user, companies: [company], last_company_id: company.id

        context = {
          current_user: user
        }

        lead_time_p65 = Stats::StatisticsService.instance.percentile(65, team_member.demands.finished_with_leadtime.order(:end_date).map { |demand| demand.leadtime.to_f })
        lead_time_p80 = Stats::StatisticsService.instance.percentile(80, team_member.demands.finished_with_leadtime.order(:end_date).map { |demand| demand.leadtime.to_f })
        lead_time_p95 = Stats::StatisticsService.instance.percentile(95, team_member.demands.finished_with_leadtime.order(:end_date).map { |demand| demand.leadtime.to_f })

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

        expect(result.dig('data', 'teamMember')).to eq({
                                                         'id' => team_member.id.to_s,
                                                         'name' => team_member.name,
                                                         'startDate' => team_member.start_date.iso8601,
                                                         'endDate' => team_member.end_date.iso8601,
                                                         'jiraAccountUserEmail' => team_member.jira_account_user_email,
                                                         'jiraAccountId' => team_member.jira_account_id,
                                                         'billable' => team_member.billable,
                                                         'hoursPerMonth' => team_member.hours_per_month,
                                                         'monthlyPayment' => team_member.monthly_payment.to_f,
                                                         'teams' => [{ 'name' => team.name }, { 'name' => other_team.name }],
                                                         'projectsEndDateAsc' => {
                                                           'lastPage' => false,
                                                           'totalCount' => 2,
                                                           'totalPages' => 2,
                                                           'projects' => [{ 'id' => project.id.to_s }]
                                                         },
                                                         'projectsEndDateDesc' => {
                                                           'lastPage' => false,
                                                           'totalCount' => 2,
                                                           'totalPages' => 2,
                                                           'projects' => [{
                                                             'id' => other_project.id.to_s
                                                           }]
                                                         },
                                                         'demandsFinished' => [{ 'id' => demand_finished.id.to_s }, { 'id' => other_demand_finished.id.to_s }],
                                                         'bugs' => [{ 'id' => other_demand_finished.id.to_s }, { 'id' => bug.id.to_s }, { 'id' => other_bug.id.to_s }],
                                                         'bugsFinished' => [{ 'id' => other_demand_finished.id.to_s }],
                                                         'lastDeliveries' => [{ 'id' => demand_finished.id.to_s }],
                                                         'demandShortestLeadTime' => { 'id' => other_demand_finished.id.to_s },
                                                         'demandLargestLeadTime' => { 'id' => demand_finished.id.to_s },
                                                         'demandLeadTimeP80' => Stats::StatisticsService.instance.percentile(80, team_member.demands.finished_with_leadtime.map(&:leadtime)),
                                                         'firstDelivery' => { 'id' => other_demand_finished.id.to_s },
                                                         'demandBlocksListDesc' => {
                                                           'totalPages' => 2,
                                                           'lastPage' => false,
                                                           'totalCount' => 2,
                                                           'demandBlocks' => [{ 'id' => demand_block.id.to_s }]
                                                         },
                                                         'demandBlocksListAsc' => {
                                                           'totalPages' => 2,
                                                           'lastPage' => false,
                                                           'totalCount' => 2,
                                                           'demandBlocks' => [{ 'id' => other_demand_block.id.to_s }]
                                                         },
                                                         'leadTimeControlChartData' => {
                                                           'xAxis' => [other_demand_finished.external_id, demand_finished.external_id],
                                                           'leadTimes' => [other_demand_finished.leadtime.to_f, demand_finished.leadtime.to_f],
                                                           'leadTimeP65' => lead_time_p65,
                                                           'leadTimeP80' => lead_time_p80,
                                                           'leadTimeP95' => lead_time_p95
                                                         },
                                                         'leadTimeHistogramChartData' => { 'keys' => [23_400.0], 'values' => [2] },
                                                         'memberEffortData' => {
                                                           'xAxis' => %w[2021-11-01 2021-12-01 2022-01-01 2022-02-01 2022-03-01 2022-04-01 2022-05-01],
                                                           'yAxis' => [0.0, 0.0, 0.0, 0.0, 100.0, 100.0, 10_340.0]
                                                         },
                                                         'memberEffortDailyData' => {
                                                           'xAxis' => %w[2022-04-18 2022-04-19 2022-04-20 2022-04-21 2022-04-22 2022-04-23 2022-04-24 2022-04-25 2022-04-26 2022-04-27 2022-04-28 2022-04-29 2022-04-30 2022-05-01 2022-05-02 2022-05-03 2022-05-04 2022-05-05 2022-05-06 2022-05-07 2022-05-08 2022-05-09 2022-05-10 2022-05-11 2022-05-12 2022-05-13 2022-05-14 2022-05-15 2022-05-16 2022-05-17 2022-05-18 2022-05-20],
                                                           'yAxis' => [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10_150.0, 20.0, 0.0, 170.0]
                                                         },
                                                         'averagePullIntervalData' => {
                                                           'xAxis' => %w[2022-03-18 2022-04-18 2022-05-18],
                                                           'yAxis' => [200.0, 10.0, 89.0]
                                                         },
                                                         'projectHoursData' => {
                                                           'xAxis' => ['2022-05-31'],
                                                           'yAxisHours' => [10_170.0],
                                                           'yAxisProjectsNames' => [project.name]
                                                         },
                                                         'memberThroughputData' => [0, 0, 0, 2],
                                                         'demandEfforts' => [{ 'finishTimeToComputation' => '2022-05-03T10:00:00-03:00' }],
                                                         'demandEffortsList' => { 'demandEffortsCount' => 1 },
                                                         'teamMemberHourValueChartList' => [{ 'memberHourValueChartData' => [{ 'date' => '2022-05-31', 'hourValueRealized' => 1.838235294117647 }], 'team' => { 'id' => team.id.to_s, 'name' => team.name } }, { 'memberHourValueChartData' => [{ 'date' => '2022-05-31', 'hourValueRealized' => 0.0375 }], 'team' => { 'id' => other_team.id.to_s, 'name' => other_team.name } }]
                                                       })
      end
    end
  end

  describe '#project_additional_hours' do
    let(:company) { Fabricate :company }
    let(:project) { Fabricate :project, company: company }
    let!(:project_additional_hour) { Fabricate :project_additional_hour, project: project, obs: 'foo' }

    it 'returns the members in the company' do
      query =
        %(
        query {
          projectAdditionalHours(projectId: #{project.id}) {
            eventDate
            hoursType
            hours
            obs
            project {
              name
            }
          }
        }
      )

      user = Fabricate :user

      context = {
        current_user: user
      }

      result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json
      expect(result.dig('data', 'projectAdditionalHours').pluck('obs')).to eq ['foo']
      expect(result.dig('data', 'projectAdditionalHours').pluck('hours')).to eq [project_additional_hour.hours]
      expect(result.dig('data', 'projectAdditionalHours').pluck('hoursType')).to eq [0]
      expect(result.dig('data', 'projectAdditionalHours').pluck('eventDate')).to eq [project_additional_hour.event_date.iso8601]
    end
  end

  describe '#work_item_types' do
    it "retrieves the list of work item types to the logged user's last company" do
      query =
        %(query {
          workItemTypes {
            name
          }
        })

      company = Fabricate :company
      Fabricate :work_item_type, company: company, name: 'Cornojob', item_level: :demand
      Fabricate :work_item_type, company: company, name: 'Beltrano', item_level: :demand
      user = Fabricate :user, companies: [company], last_company_id: company.id

      context = {
        current_user: user
      }

      result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

      expect(result.dig('data', 'workItemTypes').pluck('name')).to eq %w[Beltrano Cornojob]
    end
  end

  describe '#me' do
    context 'without projects search' do
      it 'retrieves current logged in user' do
        query =
          %(query {
          me {
            id
            currentCompany {
              id
              workItemTypes {
                id
              }
              products {
                id
              }
            }
            projects {
              id
            }
            projectsActive {
              id
            }
          }
        })

        company = Fabricate :company
        work_item_type = Fabricate :work_item_type, company: company, name: 'Cornojob', item_level: :demand
        first_product = Fabricate :product, company: company, name: 'bbb'
        second_product = Fabricate :product, company: company, name: 'aaa'
        third_product = Fabricate :product, company: company, name: 'ccc'

        first_project = Fabricate :project, status: :executing, products: [first_product], end_date: 2.days.from_now, name: 'zzz'
        second_project = Fabricate :project, status: :executing, products: [second_product], end_date: 2.days.from_now, name: 'aaa'
        Fabricate :project, status: :finished, products: [second_product], end_date: 2.days.from_now, name: 'ccc'
        Fabricate :project, status: :executing, products: [second_product], end_date: 2.days.ago, name: 'ddd'
        Fabricate :project, status: :executing, products: [third_product], end_date: 2.days.from_now, name: 'bbb'

        user = Fabricate :user, companies: [company], products: [first_product, second_product], last_company_id: company.id
        context = { current_user: user }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'me', 'id')).to eq user.id.to_s
        expect(result.dig('data', 'me', 'currentCompany', 'id')).to eq company.id.to_s
        expect(result.dig('data', 'me', 'currentCompany', 'products').pluck('id')).to eq [second_product.id.to_s, first_product.id.to_s, third_product.id.to_s]
        expect(result.dig('data', 'me', 'projects').pluck('id')).to eq [second_project.id.to_s, first_project.id.to_s]
        expect(result.dig('data', 'me', 'projectsActive').pluck('id')).to eq [second_project.id.to_s, first_project.id.to_s]
        expect(result.dig('data', 'me', 'currentCompany', 'workItemTypes')).to eq [{ 'id' => work_item_type.id.to_s }]
      end
    end

    context 'with projects search' do
      it 'retrieves current logged in user' do
        query =
          %(query {
          me {
            id
            projects(name: "ddd") {
              id
            }
          }
        })

        company = Fabricate :company
        first_product = Fabricate :product, company: company
        second_product = Fabricate :product, company: company
        third_product = Fabricate :product, company: company

        Fabricate :project, status: :executing, products: [first_product], end_date: 2.days.from_now, name: 'zzz'
        Fabricate :project, status: :executing, products: [second_product], end_date: 2.days.from_now, name: 'aaa'
        Fabricate :project, status: :finished, products: [second_product], end_date: 2.days.from_now, name: 'ccc'
        project = Fabricate :project, status: :executing, products: [second_product], end_date: 2.days.ago, name: 'ddd'
        Fabricate :project, status: :executing, products: [third_product], end_date: 2.days.from_now, name: 'bbb'

        user = Fabricate :user, products: [first_product, second_product]

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'me', 'id')).to eq user.id.to_s
        expect(result.dig('data', 'me', 'projects').pluck('id')).to eq [project.id.to_s]
      end
    end
  end

  describe '#membership' do
    it 'retrieves the membership' do
      membership = Fabricate :membership

      query =
        %(query {
            membership(id: #{membership.id}) {
              id
            }
          })

      result = FlowClimateSchema.execute(query, variables: nil).as_json

      expect(result.dig('data', 'membership', 'id')).to eq membership.id.to_s
    end
  end

  describe '#memberships' do
    it 'retrieves the memberships for the team' do
      team = Fabricate :team

      member = Fabricate :team_member, name: 'zzz'
      other_member = Fabricate :team_member, name: 'aaa'
      membership = Fabricate :membership, team: team, team_member: member
      other_membership = Fabricate :membership, team: team, team_member: other_member
      Fabricate :membership

      query =
        %(query {
            memberships(teamId: #{team.id}) {
              id
            }
          })

      result = FlowClimateSchema.execute(query, variables: nil).as_json

      expect(result.dig('data', 'memberships').pluck('id')).to eq [other_membership.id.to_s, membership.id.to_s]
    end
  end

  describe '#jira_project_config' do
    context 'with valid ID' do
      it 'returns the demand' do
        jira_project_config = Fabricate :jira_project_config

        query =
          %(
          query {
            jiraProjectConfig(id: "#{jira_project_config.id}") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'jiraProjectConfig')['id']).to eq jira_project_config.id.to_s
      end
    end

    context 'with invalid ID' do
      it 'returns nil' do
        query =
          %(
          query {
            jiraProjectConfig(id: "foo") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'jiraProjectConfig')).to be_nil
      end
    end
  end

  describe '#jira_project_config_list' do
    context 'with valid ID' do
      it 'returns the config list' do
        jira_project_config = Fabricate :jira_project_config, id: 1

        query =
          %(
          query {
            jiraProjectConfigList(id: "#{jira_project_config.project.id}") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'jiraProjectConfigList').first['id']).to eq jira_project_config.id.to_s
      end
    end

    context 'with invalid ID' do
      it 'returns nil' do
        query =
          %(
          query {
            jiraProjectConfigList(project_id: "foo") {
              id
            }
          }
        )

        user = Fabricate :user

        context = {
          current_user: user
        }

        result = FlowClimateSchema.execute(query, variables: nil, context: context).as_json

        expect(result.dig('data', 'jiraProjectConfigList')).to be_nil
      end
    end
  end
end
