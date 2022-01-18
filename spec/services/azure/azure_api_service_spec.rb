# frozen_string_literal: true

RSpec.describe Azure::AzureApiService, type: :service do
  let(:company) { Fabricate :company }
  let(:product) { Fabricate :product, company: company }
  let(:azure_account) { Fabricate :azure_account, company: company, azure_organization: 'bla', username: 'foo', password: 'bar' }

  describe '#teams' do
    context 'when success' do
      it 'returns the azure response with the projects list' do
        expect(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/_apis/teams?api-version=6.1-preview.3",
                                               basic_auth: { username: azure_account.username, password: azure_account.password },
                                               headers: { 'Content-Type' => 'application/json' })).once
        described_class.new(azure_account).teams
      end
    end

    context 'when failure' do
      it 'returns an empty hash and logs the error' do
        allow(HTTParty).to(receive(:get)).and_raise(Errno::ECONNREFUSED)
        expect(Rails.logger).to(receive(:error)).exactly(5).times

        expect(described_class.new(azure_account).teams).to eq({})
      end
    end
  end

  describe '#work_items_ids' do
    let(:azure_product_config) { Fabricate :azure_product_config, azure_account: azure_account, product: product }
    let(:azure_team) { Fabricate :azure_team, azure_product_config: azure_product_config }
    let!(:azure_project) { Fabricate :azure_project, azure_team: azure_team }

    context 'when success' do
      it 'returns the azure response with the work items ids inside the project and team' do
        query = { 'query' => 'SELECT Id FROM WorkItems' }
        expect(HTTParty).to(receive(:post).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_product_config.azure_team.azure_project.project_id}/#{azure_product_config.azure_team.team_id}/_apis/wit/wiql?api-version=6.0",
                                                body: query.to_json,
                                                basic_auth: { username: azure_account.username, password: azure_account.password },
                                                headers: { 'Content-Type' => 'application/json' })).once

        described_class.new(azure_account).work_items_ids(azure_product_config)
      end
    end

    context 'when failure' do
      let(:azure_product_config) { Fabricate :azure_product_config, azure_account: azure_account, product: product }

      it 'returns an empty hash and logs the error' do
        allow(HTTParty).to(receive(:post)).and_raise(Errno::ECONNREFUSED)
        expect(Rails.logger).to(receive(:error)).exactly(5).times

        expect(described_class.new(azure_account).work_items_ids(azure_product_config)).to eq({})
      end
    end
  end

  describe '#work_item' do
    let(:azure_product_config) { Fabricate :azure_product_config, azure_account: azure_account, product: product }
    let(:azure_team) { Fabricate :azure_team, azure_product_config: azure_product_config }
    let!(:azure_project) { Fabricate :azure_project, azure_team: azure_team }

    context 'when success' do
      it 'returns the azure response with the work item info' do
        work_item_id = 1

        expect(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/#{work_item_id}?$expand=all&api-version=6.1-preview.3",
                                               basic_auth: { username: azure_account.username, password: azure_account.password },
                                               headers: { 'Content-Type' => 'application/json' })).once

        described_class.new(azure_account).work_item(work_item_id, azure_project.project_id)
      end
    end

    context 'when failure' do
      let(:azure_product_config) { Fabricate :azure_product_config, azure_account: azure_account, product: product }

      it 'returns an empty hash and logs the error' do
        allow(HTTParty).to(receive(:get)).and_raise(Errno::ECONNREFUSED)
        expect(Rails.logger).to(receive(:error)).exactly(5).times

        expect(described_class.new(azure_account).work_item(1, 'foo')).to eq({})
      end
    end
  end
end
