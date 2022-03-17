# frozen_string_literal: true

RSpec.describe Types::MutationType do
  describe 'generate_replenishing_cache' do
    describe '.resolve' do
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
        it 'fails to put the job in the queue' do
          allow(Consolidations::ReplenishingConsolidationJob).to(receive(:perform_later)).and_raise(Redis::CannotConnectError)
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['generateReplenishingCache']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end

  describe 'send auth token' do
    describe '.resolve' do
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

        it 'succeeds to send the auth token to the user' do
          user = Fabricate :user
          context = {
            current_user: user
          }
          result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
          expect(result['data']['sendAuthToken']['statusMessage']).to eq('SUCCESS')
        end
      end

      context 'when context does not have current user' do
        let(:mutation) do
          %(mutation {
              sendAuthToken(companyId: #{company.id}) {
                statusMessage
              }
            })
        end

        it 'fails to send the auth token to the user' do
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
    describe '.resolve' do
      let(:team) { Fabricate :team }
      let(:mutation) do
        %(mutation {
            deleteTeam(teamId: "#{team.id}") {
              statusMessage
            }
          })
      end

      context 'when the team exists' do
        it 'succeeds to delete the object' do
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['deleteTeam']['statusMessage']).to eq('SUCCESS')
          expect(Team.all.count).to eq 0
        end
      end

      context 'when the object is not valid' do
        it 'fails to put the job in the queue' do
          allow_any_instance_of(Team).to(receive(:destroy)).and_return(false)
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['deleteTeam']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end

  describe 'update_team' do
    describe '.resolve' do
      let(:team) { Fabricate :team }
      let(:mutation) do
        %(mutation {
            updateTeam(teamId: "#{team.id}", name: "foo", maxWorkInProgress: 2) {
              statusMessage
            }
          })
      end

      context 'when the team exists' do
        it 'succeeds to delete the object' do
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['updateTeam']['statusMessage']).to eq('SUCCESS')
          expect(team.reload.name).to eq 'foo'
          expect(team.reload.max_work_in_progress).to eq 2
        end
      end

      context 'when the object is not valid' do
        it 'fails to put the job in the queue' do
          allow_any_instance_of(Team).to(receive(:update)).and_return(false)
          result = FlowClimateSchema.execute(mutation).as_json
          expect(result['data']['updateTeam']['statusMessage']).to eq('FAIL')
        end
      end
    end
  end
end
