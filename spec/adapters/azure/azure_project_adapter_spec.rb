# frozen_string_literal: true

RSpec.describe Azure::AzureProjectAdapter do
  describe '#projects' do
    let(:company) { Fabricate :company }
    let(:azure_account) { Fabricate :azure_account, company: company }

    context 'when success' do
      context 'with registered products' do
        it 'returns an array with the products' do
          product = Fabricate :product, company: company, name: 'FlowClimate'
          azure_product_config = Fabricate :azure_product_config, product: product, azure_account: azure_account
          azure_team = Fabricate :azure_team, azure_product_config: azure_product_config, team_name: 'FlowClimate Team', team_id: '75359256-f8b4-4108-8f9c-4dbfb8975548'
          Fabricate :azure_project, azure_team: azure_team, project_name: 'FlowClimate', project_id: '19dd7898-d318-4896-8797-afaf2320dcd3'

          mocked_azure_return = file_fixture('azure_teams_list.json').read

          allow(HTTParty).to(receive(:get)).once { JSON.parse(mocked_azure_return) }

          expect(described_class.new(azure_account).products).to eq [product]
        end
      end

      context 'without registered products' do
        it 'creates the product and the azure config for it' do
          mocked_azure_return = file_fixture('azure_teams_list.json').read
          allow(HTTParty).to(receive(:get)).once { JSON.parse(mocked_azure_return) }
          expect(described_class.new(azure_account).products).to eq [Product.all.first]
          expect(Azure::AzureTeam.all.count).not_to be_zero
          expect(Azure::AzureProject.all.count).not_to be_zero
          expect(Azure::AzureProductConfig.all.count).not_to be_zero
        end
      end
    end

    context 'when failed' do
      it 'calls the logger and returns an empty array' do
        not_found_response = Net::HTTPResponse.new(1.0, 404, 'not found')
        allow(HTTParty).to(receive(:get)).once { not_found_response }

        expect(Rails.logger).to(receive(:error)).once
        expect(described_class.new(azure_account).products).to eq []
      end
    end
  end
end
