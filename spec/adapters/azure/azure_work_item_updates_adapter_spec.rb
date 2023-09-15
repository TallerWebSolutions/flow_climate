# frozen_string_literal: true

RSpec.describe Azure::AzureWorkItemUpdatesAdapter do
  describe '#transitions' do
    let(:company) { Fabricate :company }
    let!(:user) { Fabricate :user, companies: [company], email: 'celso@taller.net.br' }
    let(:team) { Fabricate :team, company: company }
    let(:azure_account) { Fabricate :azure_account, company: company }
    let(:stage) { Fabricate :stage, name: 'TO do', company: company, integration_id: azure_account.id, stage_type: :backlog }
    let(:azure_product_config) { Fabricate :azure_product_config, azure_account: azure_account }
    let!(:azure_team) { Fabricate :azure_team, azure_product_config: azure_product_config, team_name: 'FlowClimate Team', team_id: '75359256-f8b4-4108-8f9c-4dbfb8975548' }
    let!(:azure_project) { Fabricate :azure_project, azure_team: azure_team, project_name: 'FlowClimate', project_id: '19dd7898-d318-4896-8797-afaf2320dcd3' }
    let(:demand) { Fabricate :demand, external_id: 1, company: company, team: team }

    context 'when success' do
      context 'with not discarded item' do
        it 'returns the transitions' do
          first_item_mocked_azure_return = file_fixture('azure_work_item_updates.json').read

          Fabricate :demand_transition, demand: demand, stage: stage, last_time_out: nil

          allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1/updates?api-version=6.1-preview.3",
                                                basic_auth: { username: azure_account.username, password: azure_account.password },
                                                headers: { 'Content-Type' => 'application/json' })).once { JSON.parse(first_item_mocked_azure_return) }

          described_class.new(azure_account).transitions(demand, azure_product_config.azure_team.azure_project.project_id)

          expect(Stage.all.map(&:name)).to match_array ['To Do', 'Doing', 'Done']
          expect(Stage.all.map { |s| [s.name, s.projects] }).to match_array [['To Do', [demand.project]], ['Doing', [demand.project]], ['Done', [demand.project]]]
          expect(DemandTransition.order(:id).map(&:last_time_in)).to eq %w[2022-01-13T14:05:06.22Z 2022-01-17T13:34:43.95Z 2022-01-24T15:02:14.39Z]
          expect(DemandTransition.order(:id).map(&:last_time_out)).to eq ['2022-01-17T13:34:43.95Z', '2022-01-24T15:02:14.39Z', nil]
          expect(TeamMember.order(:id).map(&:name)).to eq ['Celso Martins']
          expect(TeamMember.order(:id).map(&:user_id)).to eq [user.id]
        end
      end

      context 'with discarded item' do
        it 'returns the transitions' do
          Fabricate :stage, company: company, name: 'Done', stage_type: :trashcan, integration_id: azure_account.id

          first_item_mocked_azure_return = file_fixture('azure_work_item_updates.json').read

          allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1/updates?api-version=6.1-preview.3",
                                                basic_auth: { username: azure_account.username, password: azure_account.password },
                                                headers: { 'Content-Type' => 'application/json' })).once { JSON.parse(first_item_mocked_azure_return) }

          described_class.new(azure_account).transitions(demand, azure_product_config.azure_team.azure_project.project_id)

          expect(Stage.all.map(&:name)).to match_array ['To Do', 'Doing', 'Done']
          expect(Stage.all.map { |s| [s.name, s.projects] }).to match_array [['To Do', [demand.project]], ['Doing', [demand.project]], ['Done', [demand.project]]]
          expect(DemandTransition.order(:id).map(&:last_time_in)).to eq %w[2022-01-13T14:05:06.22Z 2022-01-17T13:34:43.95Z 2022-01-24T15:02:14.39Z]
          expect(DemandTransition.order(:id).map(&:last_time_out)).to eq ['2022-01-17T13:34:43.95Z', '2022-01-24T15:02:14.39Z', nil]
          expect(TeamMember.order(:id).map(&:name)).to eq ['Celso Martins']
          expect(TeamMember.order(:id).map(&:user_id)).to eq [user.id]
          expect(demand.discarded_at).to eq '2022-01-24T15:02:14.39Z'
        end
      end
    end

    context 'when failed' do
      it 'calls the logger and returns an empty array' do
        not_found_response = Net::HTTPResponse.new(1.0, 404, 'not found')
        allow(HTTParty).to(receive(:get)).once { not_found_response }

        expect(Rails.logger).to(receive(:error)).once
        expect(described_class.new(azure_account).transitions(demand, azure_product_config.azure_team.azure_project)).to eq []
      end
    end
  end
end
