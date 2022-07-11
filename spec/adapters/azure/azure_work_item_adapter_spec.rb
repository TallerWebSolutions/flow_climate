# frozen_string_literal: true

RSpec.describe Azure::AzureWorkItemAdapter do
  let(:company) { Fabricate :company }
  let!(:feature) { Fabricate :work_item_type, company: company, name: 'Feature' }

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
        it 'returns the created portfolio unit' do
          first_item_mocked_azure_return = file_fixture('azure_work_item_3_expanded.json').read
          first_response = instance_double(HTTParty::Response, parsed_response: JSON.parse(first_item_mocked_azure_return))

          allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                basic_auth: { username: azure_account.username, password: azure_account.password },
                                                headers: { 'Content-Type' => 'application/json' })).once { first_response }

          described_class.new(azure_account).work_item(1, azure_product_config.azure_team.azure_project)

          expect(PortfolioUnit.all.map(&:name)).to eq ['Primeira issue']
        end
      end

      context 'when user story' do
        context 'with valid parent and it does not exist' do
          it 'creates the task and the parent' do
            first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            first_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(first_item_mocked_azure_return))
            second_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(second_item_mocked_azure_return))

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return(first_response)

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).and_return(second_response)

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Demand.all.count).to eq 1
            expect(Task.all.count).to eq 1

            expect(Demand.all.map(&:demand_title)).to eq ['Primeiro Contato']
            expect(Demand.all.map(&:demand_type)).to eq ['AV']

            expect(Task.all.map(&:title)).to eq ['Primeira issue']
            expect(Task.all.map(&:task_type)).to eq ['Default']

            expect(WorkItemType.all.map(&:name)).to match_array %w[Default AV Feature]
            expect(WorkItemType.all.map(&:item_level)).to match_array %w[demand task demand]
          end
        end

        context 'with an already existent and discarded issue' do
          it 'does not read the issue if the demand was not undiscarded first' do
            demand = Fabricate :demand, company: company, team: team, external_id: 1, discarded_at: 2.weeks.ago
            task = Fabricate :task, demand: demand, external_id: 2, discarded_at: 2.weeks.ago

            first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            first_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(first_item_mocked_azure_return))
            second_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(second_item_mocked_azure_return))

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return(first_response)

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return(second_response)

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Demand.all.count).to eq 1
            expect(Task.all.count).to eq 1

            expect(demand.reload.discarded_at).not_to be_nil
            expect(task.reload.discarded_at).not_to be_nil
          end

          it 'reads the issue if the demand was undiscarded first' do
            demand = Fabricate :demand, company: company, team: team, external_id: 1, discarded_at: nil
            task = Fabricate :task, demand: demand, external_id: 2, discarded_at: 2.weeks.ago

            first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            first_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(first_item_mocked_azure_return))
            second_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(second_item_mocked_azure_return))

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return(first_response)

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).and_return(second_response)

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Demand.all.count).to eq 1
            expect(Task.all.count).to eq 1

            expect(demand.reload.discarded_at).to be_nil
            expect(task.reload.discarded_at).to be_nil
          end
        end

        context 'with an already existent issue and it is in another project' do
          it 'reads the new project and remove in the previous project' do
            demand_project = Fabricate :project, company: company, team: team

            demand = Fabricate :demand, company: company, team: team, external_id: 5, project: demand_project
            Fabricate :task, demand: demand, external_id: 2

            first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            first_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(first_item_mocked_azure_return))
            second_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(second_item_mocked_azure_return))

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return(first_response)

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).and_return(second_response)

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Demand.all.count).to eq 2
            expect(Task.all.count).to eq 1
          end
        end

        context 'with invalid parent' do
          it 'returns the created demand and does not process the parent' do
            second_item_mocked_azure_return = file_fixture('azure_work_item_2_expanded.json').read

            first_response = instance_double(HTTParty::Response, parsed_response: JSON.parse(second_item_mocked_azure_return))

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/2?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once { first_response }

            allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                  basic_auth: { username: azure_account.username, password: azure_account.password },
                                                  headers: { 'Content-Type' => 'application/json' })).once.and_return({})

            described_class.new(azure_account).work_item(2, azure_product_config.azure_team.azure_project)

            expect(Task.all.count).to eq 0
            expect(Demand.all.count).to eq 0
          end
        end
      end

      context 'when feature' do
        it 'creates the demand' do
          first_item_mocked_azure_return = file_fixture('azure_work_item_1_expanded.json').read

          first_response = instance_double(HTTParty::Response, code: 200, parsed_response: JSON.parse(first_item_mocked_azure_return))

          allow(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/#{azure_project.project_id}/_apis/wit/workitems/1?$expand=all&api-version=6.1-preview.3",
                                                basic_auth: { username: azure_account.username, password: azure_account.password },
                                                headers: { 'Content-Type' => 'application/json' })).once.and_return(first_response)

          described_class.new(azure_account).work_item(1, azure_product_config.azure_team.azure_project)

          expect(Demand.all.count).to eq 1
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
