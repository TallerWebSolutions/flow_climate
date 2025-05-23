# frozen_string_literal: true

RSpec.describe Types::MutationType do
  describe 'generate_replenishing_cache' do
    describe '#resolve' do
      let(:team) { Fabricate :team }
      let(:mutation) do
        %(mutation {
            generateReplenishingCache(teamId: "#{team.id}") {
              statusMessage
            }
          })
      end

      context 'when the team exists' do
        it 'succeeds to put the job in the queue' do
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['generateReplenishingCache']['statusMessage']).to eq('SUCCESS')
        end
      end

      context 'when redis server is not working' do
        it 'fails' do
          allow(Consolidations::ReplenishingConsolidationJob).to(receive(:perform_later)).and_raise(Redis::CannotConnectError)
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['generateReplenishingCache']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end

  describe 'generate_project_cache' do
    describe '#resolve' do
      let(:project) { Fabricate :project }
      let(:mutation) do
        %(mutation {
            generateProjectCache(projectId: "#{project.id}") {
              statusMessage
            }
          })
      end

      context 'when the project exists' do
        it 'succeeds' do
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['generateProjectCache']['statusMessage']).to eq('SUCCESS')
        end
      end

      context 'when redis server is not working' do
        it 'fails' do
          allow(Consolidations::ProjectConsolidationJob).to(receive(:perform_later)).and_raise(Redis::CannotConnectError)
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['generateProjectCache']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end

  describe 'send_auth_token' do
    describe '#resolve' do
      let(:company) { Fabricate :company }

      context 'when context has current user' do
        let(:mutation) do
          %(mutation {
              me { id }
              sendAuthToken(companyId: #{company.id}) {
                statusMessage
              }
            })
        end

        it 'succeeds' do
          user = Fabricate :user
          context = { current_user: user }

          result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
          expect(result['data']['sendAuthToken']['statusMessage']).to eq('SUCCESS')
        end
      end

      context 'when context does not have the current user' do
        let(:mutation) do
          %(mutation {
              sendAuthToken(companyId: #{company.id}) {
                statusMessage
              }
            })
        end

        it 'fails' do
          context = {
            current_user: nil
          }

          result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
          expect(result['data']['sendAuthToken']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end

  describe '#delete_team' do
    let(:team) { Fabricate :team }
    let(:mutation) do
      %(mutation {
            deleteTeam(teamId: "#{team.id}") {
              statusMessage
            }
          })
    end

    context 'when the team exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteTeam']['statusMessage']).to eq('SUCCESS')
        expect(Team.count).to eq 0
      end
    end

    context 'when the object is not valid' do
      it 'fails' do
        allow_any_instance_of(Team).to(receive(:destroy)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteTeam']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#update_team' do
    let(:team) { Fabricate :team }
    let(:mutation) do
      %(mutation {
            updateTeam(teamId: "#{team.id}", name: "foo", maxWorkInProgress: 2) {
              statusMessage
            }
          })
    end

    context 'when the team exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['updateTeam']['statusMessage']).to eq('SUCCESS')
        expect(team.reload.name).to eq 'foo'
        expect(team.reload.max_work_in_progress).to eq 2
      end
    end

    context 'when the object is not valid' do
      it 'fails' do
        allow_any_instance_of(Team).to(receive(:update)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['updateTeam']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#delete_team_member' do
    let(:team_member) { Fabricate :team_member }
    let(:mutation) do
      %(mutation {
            deleteTeamMember(teamMemberId: "#{team_member.id}") {
              statusMessage
            }
          })
    end

    context 'when the team member exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteTeamMember']['statusMessage']).to eq('SUCCESS')
        expect(TeamMember.count).to eq 0
      end
    end

    context 'when the team member does not exist' do
      it 'fails' do
        allow(TeamMember).to(receive(:find_by)).and_return(nil)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteTeamMember']['statusMessage']).to eq('FAIL')
        expect(TeamMember.count).to eq 1
      end
    end

    context 'when the object is not valid' do
      it 'fails' do
        allow_any_instance_of(TeamMember).to(receive(:destroy)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteTeamMember']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#save_membership' do
    let(:team) { Fabricate :team }
    let(:membership) { Fabricate :membership, team: team }

    context 'when the membership exists' do
      let(:mutation) do
        %(mutation {
            saveMembership(membershipId: "#{membership.id}", memberRole: 1, startDate: "#{1.day.ago.to_date.iso8601}", endDate: "#{Time.zone.today.iso8601}", hoursPerMonth: 80, effortPercentage: 50.0) {
              statusMessage
            }
          })
      end

      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['saveMembership']['statusMessage']).to eq('SUCCESS')
        expect(membership.reload).to be_manager
      end
    end

    context 'when the object is not valid' do
      let(:mutation) do
        %(mutation {
            saveMembership(membershipId: "foo", memberRole: 1, startDate: "#{1.day.ago.to_date.iso8601}", endDate: "#{Time.zone.today.iso8601}", hoursPerMonth: 80, effortPercentage: 50.0) {
              statusMessage
            }
          })
      end

      it 'fails' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['saveMembership']['statusMessage']).to eq('NOT_FOUND')
      end
    end
  end

  describe '#create_team' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    let(:team) { Fabricate :team }
    let(:mutation) do
      %(mutation {
            createTeam(name: "foo", maxWorkInProgress: 2) {
              statusMessage
            }
          })
    end

    context 'when the team exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['createTeam']['statusMessage']).to eq('SUCCESS')
        created_team = Team.last
        expect(created_team.name).to eq 'foo'
        expect(created_team.max_work_in_progress).to eq 2
      end
    end

    context 'when the object is not valid' do
      it 'fails' do
        allow_any_instance_of(Team).to(receive(:valid?)).and_return(false)
        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['createTeam']['statusMessage']).to eq('FAIL')
      end
    end

    context 'when context does not have the current user' do
      it 'fails' do
        context = {
          current_user: nil
        }

        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['createTeam']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#create_service_delivery_review_action' do
    let(:membership) { Fabricate :membership, id: 2 }
    let(:sdr) { Fabricate :service_delivery_review }

    context 'with valid data' do
      let(:mutation) do
        %(mutation {
          createServiceDeliveryReviewAction(
            actionType: 2
            deadline: "#{Time.zone.tomorrow}"
            description: "descriçao"
            membershipId: "#{membership.id}"
            sdrId: "#{sdr.id}"
          ) {
            statusMessage
            serviceDeliveryReviewAction{
              id
            }
          }
        })
      end

      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['createServiceDeliveryReviewAction']['statusMessage']).to eq('SUCCESS')
        expect(ServiceDeliveryReviewActionItem.count).to eq 1
      end
    end

    context 'with invalid data' do
      let(:mutation) do
        %(mutation {
          createServiceDeliveryReviewAction(
            actionType: 2
            deadline: "#{Time.zone.tomorrow}"
            description: "descriçao"
            membershipId: "foo"
            sdrId: "#{sdr.id}"
          ) {
            statusMessage
            serviceDeliveryReviewAction{
              id
            }
          }
        })
      end

      it 'fails' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['createServiceDeliveryReviewAction']['statusMessage']).to eq('FAIL')
        expect(ServiceDeliveryReviewActionItem.count).to eq 0
      end
    end
  end

  describe '#delete_service_delivery_review' do
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company, company_id: company.id }
    let(:service_delivery_review) { Fabricate :service_delivery_review, id: 2 }

    let(:mutation) do
      %(mutation {
        deleteServiceDeliveryReview(
          sdrId: #{service_delivery_review.id}
        ) {
          statusMessage
        }
      })
    end

    context 'delete sdr success' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteServiceDeliveryReview']['statusMessage']).to eq('SUCCESS')
      end
    end

    context 'delete sdr fail' do
      it 'failed' do
        allow_any_instance_of(ServiceDeliveryReview).to(receive(:destroy)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteServiceDeliveryReview']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#create_service_delivery_review' do
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company, company_id: company.id }

    context 'with unauthenticated user' do
      let(:mutation) do
        %(mutation {
          createServiceDeliveryReview(
            date: "#{Time.zone.today.iso8601}",
            productId: #{product.id},
            maxExpediteLate: 2.0,
            maxLeadtime: 2.0,
            maxQuality: 2.0,
            minExpediteLate: 2.0,
            minLeadtime: 2.0,
            minQuality: 2.0,
            sla: 2
          ) {
            statusMessage
          }
        })
      end

      it 'fails' do
        expect(ServiceDeliveryReviewGeneratorJob).not_to(receive(:perform_later))
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['createServiceDeliveryReview']['statusMessage']).to eq('FAIL')
      end
    end

    context 'with authenticated user' do
      let(:user) { Fabricate :user }
      let(:context) { { current_user: user } }

      context 'with valid data' do
        let(:mutation) do
          %(mutation {
          createServiceDeliveryReview(
            date: "#{Time.zone.today.iso8601}",
            productId: #{product.id},
            maxExpediteLate: 2.0,
            maxLeadtime: 2.0,
            maxQuality: 2.0,
            minExpediteLate: 2.0,
            minLeadtime: 2.0,
            minQuality: 2.0,
            sla: 2
          ) {
            statusMessage
          }
        })
        end

        it 'succeeds' do
          expect(ServiceDeliveryReviewGeneratorJob).to(receive(:perform_later)).once
          result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
          expect(result['data']['createServiceDeliveryReview']['statusMessage']).to eq('SUCCESS')
        end
      end

      context 'with invalid data' do
        let(:mutation) do
          %(mutation {
          createServiceDeliveryReview(
            date: "#{Time.zone.today.iso8601}",
            productId: #{product.id},
            maxExpediteLate: 2.0,
            maxLeadtime: 2.0,
            maxQuality: 2.0,
            minExpediteLate: 2.0,
            minLeadtime: 2.0,
            minQuality: 2.0,
            sla: 2
          ) {
            statusMessage
          }
        })
        end

        it 'fails' do
          allow_any_instance_of(ServiceDeliveryReview).to(receive(:valid?)).and_return(false)
          expect(ServiceDeliveryReviewGeneratorJob).not_to(receive(:perform_later))
          result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
          expect(result['data']['createServiceDeliveryReview']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end

  describe '#create_portfolio_unit' do
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company }
    let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz' }

    context 'with valid data' do
      let(:mutation) do
        %(mutation {
          createPortfolioUnit(parentId: #{portfolio_unit.id}, productId: #{product.id},  name: "foo", portfolioUnitType: "epic", jiraMachineName: "teste") {
            statusMessage
          }
        })
      end

      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['createPortfolioUnit']['statusMessage']).to eq('SUCCESS')
      end
    end

    context 'when the object is not valid' do
      let(:mutation) do
        %(mutation {
          createPortfolioUnit(parentId: "foo", productId: #{product.id},  name: "foo", portfolioUnitType: "epic", jiraMachineName: "teste") {
            statusMessage
          }
        })
      end

      it 'fails' do
        allow_any_instance_of(PortfolioUnit).to(receive(:valid?)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['createPortfolioUnit']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#update_portfolio_unit' do
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, id: 315, company: company }
    let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'zzz', id: 2087, product_id: 315, portfolio_unit_type: 1 }

    context 'with valid data' do
      let(:mutation) do
        %(mutation {
          updatePortfolioUnit(parentId: #{portfolio_unit.id}, productId: #{product.id}, unitId: #{portfolio_unit.id}, name: "foo", portfolioUnitType: "epic", jiraMachineName: "teste") {
            statusMessage
          }
        })
      end

      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['updatePortfolioUnit']['statusMessage']).to eq('SUCCESS')
      end
    end

    context 'when the object is not valid' do
      let(:mutation) do
        %(mutation {
          updatePortfolioUnit(parentId: "foo", productId: #{product.id}, unitId: 10, name: "foo", portfolioUnitType: "epic", jiraMachineName: "teste") {
            statusMessage
          }
        })
      end

      it 'fails' do
        allow_any_instance_of(PortfolioUnit).to(receive(:valid?)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json

        expect(result['data']['updatePortfolioUnit']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#create_project_additional_hours' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    let(:project) { Fabricate :project, company: company }
    let(:mutation) do
      %(mutation {
            createProjectAdditionalHours(projectId: #{project.id}, eventDate: "#{Time.zone.today.iso8601}",hoursType: 0, hours: 14.2, obs: "bla") {
              statusMessage
            }
          })
    end

    context 'when the project exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['createProjectAdditionalHours']['statusMessage']).to eq('SUCCESS')
        created_hours = ProjectAdditionalHour.last
        expect(created_hours.project).to eq project
        expect(created_hours.hours_type).to eq 'meeting'
        expect(created_hours.event_date).to eq Time.zone.today
        expect(created_hours.hours).to eq 14.2
        expect(created_hours.obs).to eq 'bla'
      end
    end

    context 'when the object is not valid' do
      it 'fails to put the job in the queue' do
        allow_any_instance_of(ProjectAdditionalHour).to(receive(:valid?)).and_return(false)
        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['createProjectAdditionalHours']['statusMessage']).to eq('FAIL')
      end
    end

    context 'when context does not have the current user' do
      it 'fails to send the auth token to the user' do
        context = {
          current_user: nil
        }

        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['createProjectAdditionalHours']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#update_team_member' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    let(:team_member) { Fabricate :team_member, company: company, name: 'bar' }
    let!(:base_date) { Time.zone.now }

    let(:mutation) do
      %(mutation {
            updateTeamMember(teamMemberId: #{team_member.id}, name: "foo", startDate: "#{(base_date - 2.days).iso8601}", endDate: "#{base_date.iso8601}", jiraAccountUserEmail: "foo@bar.com", jiraAccountId: "12345", hoursPerMonth: 10, monthlyPayment: 200.32, billable: true) {
              updatedTeamMember {
                id
              }
            }
          })
    end

    context 'when the project exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['updateTeamMember']['updatedTeamMember']['id']).to eq team_member.id.to_s
        updated_member = team_member.reload
        expect(updated_member.name).to eq 'foo'
        expect(updated_member.start_date).to eq((base_date - 2.days).to_date)
        expect(updated_member.end_date).to eq base_date.to_date
        expect(updated_member.jira_account_user_email).to eq 'foo@bar.com'
        expect(updated_member.jira_account_id).to eq '12345'
        expect(updated_member.jira_account_id).to eq '12345'
        expect(updated_member.hours_per_month).to eq 10
        expect(updated_member.monthly_payment).to eq 200.32
        expect(updated_member.billable).to be true
      end
    end

    context 'when context does not have the current user' do
      it 'fails to update' do
        context = {
          current_user: nil
        }

        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result['data']['updateTeamMember']['updatedTeamMember']['id']).to eq team_member.id.to_s
        updated_member = team_member.reload
        expect(updated_member.name).to eq 'bar'
      end
    end
  end

  describe '#create_work_item_type' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    let(:mutation) do
      %(mutation {
          createWorkItemType(
            name: "Fire Supression"
            itemLevel: DEMAND
            qualityIndicatorType: true
          ) {
            workItemType {
              id
              name
              itemLevel
            }
          }
        })
    end

    it 'creates a new work item type' do
      result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
      created_work_item_type = WorkItemType.last
      expect(result['data']['createWorkItemType']['workItemType']['name']).to eq('Fire Supression')
      expect(result['data']['createWorkItemType']['workItemType']['itemLevel']).to eq('DEMAND')
      expect(created_work_item_type.name).to eq 'Fire Supression'
      expect(created_work_item_type).to be_a_demand
    end
  end

  describe '#delete_work_item_type' do
    let(:work_item_type) { Fabricate :work_item_type }

    let(:mutation) do
      %(mutation {
            deleteWorkItemType(workItemTypeId: "#{work_item_type.id}") {
              statusMessage
            }
          })
    end

    context 'when the work_item_type exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteWorkItemType']['statusMessage']).to eq('SUCCESS')
        expect(WorkItemType.count).to eq 0
      end
    end

    context 'when the object is not valid' do
      it 'fails' do
        allow_any_instance_of(WorkItemType).to(receive(:destroy)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteWorkItemType']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#discard_demand' do
    let(:demand) { Fabricate :demand }

    let(:mutation) do
      %(mutation{
        discardDemand(demandId: "#{demand.id}") {
          statusMessage
        }
      })
    end

    context 'when demand is discard' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['discardDemand']['statusMessage']).to eq('SUCCESS')
      end
    end

    context 'when demand is not discard' do
      it 'fails' do
        allow_any_instance_of(Demand).to(receive(:discard)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['discardDemand']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#delete_demand' do
    let(:demand) { Fabricate :demand }

    let(:mutation) do
      %(mutation{
        deleteDemand(demandId: "#{demand.id}") {
          statusMessage
        }
      })
    end

    context 'when demand is delete' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteDemand']['statusMessage']).to eq('SUCCESS')
      end
    end

    context 'when demand is not delete' do
      it 'fails' do
        allow_any_instance_of(Demand).to(receive(:destroy)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteDemand']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#create_product_risk_review' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }
    let(:product) { Fabricate :product, company: company }

    context 'with valid input' do
      it 'creates a new risk review for a product' do
        mutation = %(
            mutation {
              createProductRiskReview(
                companyId: #{company.id}
                productId: #{product.id}
                leadTimeOutlierLimit: 10
                meetingDate: "2022-03-07"
              ) {
                riskReview {
                  company {
                    id
                  }
                  product {
                    id
                  }
                }
              }
            }
          )

        FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        created_risk_review = RiskReview.last
        expect(created_risk_review.product.id).to eq product.id
        expect(created_risk_review.company.id).to eq company.id
      end
    end

    context 'with invalid product id' do
      it 'returns an error state' do
        mutation = %(
            mutation {
              createProductRiskReview(
                companyId: #{company.id}
                productId: "invalid_product_id"
                leadTimeOutlierLimit: 10
                meetingDate: "2022-03-07"
              ) {
                statusMessage
              }
            }
          )

        result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
        expect(result.dig('data', 'createProductRiskReview', 'statusMessage')).to be 'FAIL'
      end
    end
  end

  describe '#delete_product_risk_review' do
    let(:risk_review) { Fabricate :risk_review }
    let(:mutation) do
      %(mutation {
        deleteProductRiskReview(riskReviewId: "#{risk_review.id}") {
          statusMessage
        }
      })
    end

    context 'when the risk review exists' do
      it 'succeeds' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteProductRiskReview']['statusMessage']).to eq('SUCCESS')
        expect(RiskReview.count).to eq 0
      end
    end

    context 'when the object is not valid' do
      it 'fails' do
        allow_any_instance_of(RiskReview).to(receive(:destroy)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['deleteProductRiskReview']['statusMessage']).to eq('FAIL')
      end
    end
  end

  describe '#update_jira_project_config_mutation' do
    let(:jira_project_config) { Fabricate :jira_project_config }

    let(:mutation) do
      %(mutation {
          updateJiraProjectConfig(
            id: #{jira_project_config.id}
            fixVersionName: "foo"
          ) {
            statusMessage
          }
        })
    end

    context 'with valid data' do
      it 'updates the fields from mutation input' do
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['updateJiraProjectConfig']['statusMessage']).to eq('SUCCESS')
        updated_config = jira_project_config.reload
        expect(updated_config.fix_version_name).to eq 'foo'
      end
    end

    context 'with invalid data' do
      it 'fails to update' do
        allow_any_instance_of(Jira::JiraProjectConfig).to(receive(:update)).and_return(false)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['updateJiraProjectConfig']['statusMessage']).to eq('FAIL')
      end
    end

    context 'with invalid project config' do
      it 'fails to update' do
        allow(Jira::JiraProjectConfig).to(receive(:find_by)).and_return(nil)
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['updateJiraProjectConfig']['statusMessage']).to eq('NOT_FOUND')
      end
    end
  end

  describe '#synchronize_jira_project_config_mutation' do
    let(:jira_project_config) { Fabricate :jira_project_config }
    let(:current_user) { Fabricate :user }

    context 'with valid data' do
      it 'synchronizes the config and returns success' do
        mutation =
          %(mutation {
          synchronizeJiraProjectConfig(
            projectId: #{jira_project_config.project_id}
          ) {
            id
            statusMessage
          }
        })

        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['synchronizeJiraProjectConfig']).to eq({ 'id' => jira_project_config.id.to_s, 'statusMessage' => 'SUCCESS' })
      end
    end

    context 'with invalid data' do
      it 'returns not found' do
        mutation =
          %(mutation {
          synchronizeJiraProjectConfig(
            projectId: "foo"
          ) {
            id
            statusMessage
          }
        })

        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['synchronizeJiraProjectConfig']).to eq({ 'id' => nil, 'statusMessage' => 'NOT_FOUND' })
      end
    end
  end

  describe '#toggle_product_user' do
    context 'with valid data' do
      context 'when the user is not in product yet' do
        it 'adds the user to the product' do
          product = Fabricate :product
          user = Fabricate :user
          mutation = %(mutation {
            toggleProductUser(productId: #{product.id}, userId: #{user.id}) {
              statusMessage
            }
          })
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['toggleProductUser']['statusMessage']).to eq('SUCCESS')
          expect(product.users.exists?(user.id)).to be true
        end
      end

      context 'when the user is already in product' do
        it 'removes the user from the product' do
          product = Fabricate :product
          user = Fabricate :user
          product.users << user
          mutation = %(mutation {
            toggleProductUser(productId: #{product.id}, userId: #{user.id}) {
              statusMessage
            }
          })
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['toggleProductUser']['statusMessage']).to eq('SUCCESS')
          expect(product.users.exists?(user.id)).to be false
        end
      end
    end

    context 'when the product does not exist' do
      it 'fails' do
        user = Fabricate :user
        mutation = %(mutation {
            toggleProductUser(productId: "foo", userId: #{user.id}) {
              statusMessage
            }
          })
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['toggleProductUser']['statusMessage']).to eq('NOT_FOUND')
      end
    end

    context 'when the user does not exist' do
      it 'fails' do
        product = Fabricate :product
        mutation = %(mutation {
            toggleProductUser(productId: #{product.id}, userId: "foo") {
              statusMessage
            }
          })
        result = FlowClimateSchema.execute(mutation).as_json
        expect(result['data']['toggleProductUser']['statusMessage']).to eq('NOT_FOUND')
      end
    end
  end

  describe '#create_demand_effort' do
    context 'with invalid demand external id' do
      it 'returns not found error' do
        demand_transition = Fabricate :demand_transition
        item_assignment = Fabricate :item_assignment

        mutation = %(mutation {
            createDemandEffort(demandExternalId: "foo", demandTransitionId: #{demand_transition.id}, startDate: "#{11.hours.ago.iso8601}", endDate: "#{2.hours.ago.iso8601}", itemAssignmentId: #{item_assignment.id}) {
              statusMessage
            }
          })

        result = FlowClimateSchema.execute(mutation).as_json

        expect(result.dig('data', 'createDemandEffort', 'statusMessage')).to eq 'NOT_FOUND'
      end
    end

    context 'with invalid item assignment id' do
      it 'returns not found error' do
        demand = Fabricate :demand
        demand_transition = Fabricate :demand_transition

        mutation = %(mutation {
            createDemandEffort(demandExternalId: #{demand.external_id}, startDate: "#{11.hours.ago.iso8601}", endDate: "#{2.hours.ago.iso8601}", demandTransitionId: #{demand_transition.id}, itemAssignmentId: "foo") {
              statusMessage
            }
          })

        result = FlowClimateSchema.execute(mutation).as_json

        expect(result.dig('data', 'createDemandEffort', 'statusMessage')).to eq 'NOT_FOUND'
      end
    end

    context 'with invalid demand transition id' do
      it 'returns not found error' do
        demand = Fabricate :demand
        item_assignment = Fabricate :item_assignment

        mutation = %(mutation {
            createDemandEffort(demandExternalId: #{demand.external_id}, startDate: "#{11.hours.ago.iso8601}", endDate: "#{2.hours.ago.iso8601}", demandTransitionId: "foo", itemAssignmentId: #{item_assignment.id}) {
              statusMessage
            }
          })

        result = FlowClimateSchema.execute(mutation).as_json

        expect(result.dig('data', 'createDemandEffort', 'statusMessage')).to eq 'NOT_FOUND'
      end
    end

    context 'with valid arguments' do
      it 'creates the effort and assigns it to de demand' do
        demand = Fabricate :demand
        demand_transition = Fabricate :demand_transition
        item_assignment = Fabricate :item_assignment

        mutation = %(mutation {
          createDemandEffort(demandExternalId: #{demand.external_id}, startDate: "#{8.hours.ago.iso8601}", endDate: "#{2.hours.ago.iso8601}", demandTransitionId: #{demand_transition.id}, itemAssignmentId: #{item_assignment.id}) {
            statusMessage
            demandEffort {
              automaticUpdate
              effortValue
            }
          }
        })

        result = FlowClimateSchema.execute(mutation).as_json

        expect(result.dig('data', 'createDemandEffort', 'statusMessage')).to eq 'SUCCESS'
        expect(result.dig('data', 'createDemandEffort', 'demandEffort', 'automaticUpdate')).to be false
        expect(result.dig('data', 'createDemandEffort', 'demandEffort', 'effortValue')).to eq 6
      end
    end
  end

  describe '#update_demand_score_matrix' do
    context 'with invalid arguments' do
      it 'returns not found error' do
        mutation = %(mutation {
          updateDemandScoreMatrix(matrixId: "foo", answerId: "bar") {
            statusMessage
          }
        })

        result = FlowClimateSchema.execute(mutation).as_json

        expect(result.dig('data', 'updateDemandScoreMatrix', 'statusMessage')).to eq 'NOT_FOUND'
      end
    end

    context 'with valid arguments' do
      it 'updates the answer to the score matrix question' do
        old_answer = Fabricate :score_matrix_answer
        matrix = Fabricate :demand_score_matrix, score_matrix_answer: old_answer
        new_answer = Fabricate :score_matrix_answer

        mutation = %(mutation {
          updateDemandScoreMatrix(matrixId: #{matrix.id}, answerId: #{new_answer.id}) {
            statusMessage
            demandScoreMatrix {
              scoreMatrixAnswer {
                id
              }
            }
          }
        })

        expect(matrix.score_matrix_answer).to eq old_answer

        result = FlowClimateSchema.execute(mutation).as_json

        expect(result.dig('data', 'updateDemandScoreMatrix', 'statusMessage')).to eq 'SUCCESS'
        expect(result.dig('data', 'updateDemandScoreMatrix', 'demandScoreMatrix', 'scoreMatrixAnswer', 'id')).to eq new_answer.id.to_s
      end
    end
  end
end
