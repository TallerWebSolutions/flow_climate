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
      let(:mutation) do
        %(mutation {
            sendAuthToken(companyId: #{company.id}) {
              statusMessage
            }
          })
      end

      context 'when context has current user' do
        it 'succeeds to send the auth token to the user' do
          user = Fabricate :user
          context = {
            current_user: user
          }
          result = FlowClimateSchema.execute(mutation, variables: nil, context: context).as_json
          puts result
          expect(result['data']['sendAuthToken']['statusMessage']).to eq('SUCCESS')
        end
      end

      context 'when context does not have current user' do
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
end
