# frozen_string_literal: true

RSpec.describe Azure::AzureWorkItemAdapter do
  let(:company) { Fabricate :company }
  let(:azure_account) { Fabricate :azure_account, company: company }
  let(:product) { Fabricate :product, company: company, name: 'FlowClimate' }
  let(:team) { Fabricate :team, company: company, name: 'Great Team' }
  let!(:project) { Fabricate :project, company: company, team: team, name: 'FlowClimate' }

  let(:azure_product_config) { Fabricate :azure_product_config, product: product, azure_account: azure_account }
  let!(:azure_team) { Fabricate :azure_team, azure_product_config: azure_product_config, team_name: 'FlowClimate Team', team_id: '75359256-f8b4-4108-8f9c-4dbfb8975548' }
  let!(:azure_project) { Fabricate :azure_project, azure_team: azure_team, project_name: 'FlowClimate', project_id: '19dd7898-d318-4896-8797-afaf2320dcd3' }
  let!(:project_azure_custom_field) { Fabricate :azure_custom_field, azure_account: azure_account, custom_field_type: :project_name, custom_field_name: 'Custom.ProjectName' }
  let!(:team_azure_custom_field) { Fabricate :azure_custom_field, azure_account: azure_account, custom_field_type: :team_name, custom_field_name: 'Custom.TeamName' }

  describe '#work_items_ids' do
    context 'when success' do
      it 'returns an array with the work items ids' do
        mocked_azure_return = file_fixture('azure_work_items_ids_query.json').read

        allow(HTTParty).to(receive(:post)).once { JSON.parse(mocked_azure_return) }

        expect(described_class.new(azure_account).work_items_ids(azure_product_config)).to eq [1, 2]
      end
    end

    context 'when failed' do
      it 'calls the logger and returns an empty array' do
        not_found_response = Net::HTTPResponse.new(1.0, 404, 'not found')
        allow(HTTParty).to(receive(:post)).once { not_found_response }

        expect(Rails.logger).to(receive(:error)).once
        expect(described_class.new(azure_account).work_items_ids(azure_product_config)).to eq []
      end
    end
  end

  describe '#work_item' do
    context 'when success' do
      context 'when epic' do
        it 'returns the created demand' do
          first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read

          allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                basic_auth: { username: azure_account.username, password: azure_account.password },
                                                headers: { 'Content-Type' => 'application/json' })).once { JSON.parse(first_item_mocked_azure_return) }

          described_class.new(azure_account).work_item(1, azure_product_config.azure_team.azure_project)

          expect(Demand.all.count).to eq 1
        end
      end

      context 'when issue' do
        context 'with valid parent' do
          it 'returns the created demand' do
            first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once { JSON.parse(second_item_mocked_azure_return) }

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once { JSON.parse(first_item_mocked_azure_return) }

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Demand.all.count).to eq 1
          end
        end

        context 'with invalid parent' do
          it 'returns the created demand and does not process the parent' do
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once { JSON.parse(second_item_mocked_azure_return) }

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return({})

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Task.all.count).to eq 0
            expect(Demand.all.count).to eq 0
          end
        end
      end
    end

    context 'when failed' do
      it 'calls the logger and returns nil' do
        not_found_response = Net::HTTPResponse.new(1.0, 404, 'not found')
        allow(HTTParty).to(receive(:get)).once { not_found_response }

        expect(Rails.logger).to(receive(:error)).once
        described_class.new(azure_account).work_item(1, azure_product_config.azure_team.azure_project)
        expect(Demand.all.count).to be_zero
        expect(PortfolioUnit.all.count).to be_zero
      end
    end
  end
end