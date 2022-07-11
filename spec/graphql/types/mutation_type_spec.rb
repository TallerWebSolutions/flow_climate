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
          context = {
            current_user: user
          }
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

  describe 'delete_team' do
    describe '#resolve' do
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
          expect(Team.all.count).to eq 0
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
  end

  describe 'update_team' do
    describe '#resolve' do
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
  end

  describe 'create_team' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    describe '#resolve' do
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
  end

  describe 'create_project_additional_hours' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    describe '#resolve' do
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
  end

  describe 'update_team_member' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    describe '#resolve' do
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
  end

  describe 'create work item type' do
    let(:company) { Fabricate :company }
    let(:user) { Fabricate :user, companies: [company], last_company_id: company.id }
    let(:context) { { current_user: user } }

    describe '#resolve' do
      let(:mutation) do
        %(mutation {
          createWorkItemType(
            name: "Fire Supression"
            itemLevel: TASK
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
        expect(result['data']['createWorkItemType']['workItemType']['itemLevel']).to eq('TASK')
        expect(created_work_item_type.name).to eq 'Fire Supression'
        expect(created_work_item_type).to be_a_task
      end
    end
  end
end
