# frozen_string_literal: true

RSpec.describe Azure::AzureItemSyncJob do
  describe '.perform' do
    let(:company) { Fabricate :company }
    let(:azure_account) { Fabricate :azure_account, company: company }

    it 'calls the adapters and process the work item' do
      product = Fabricate :product, company: company
      azure_product_config = Fabricate :azure_product_config, product: product
      azure_team = Fabricate :azure_team, azure_product_config: azure_product_config, team_name: 'FlowClimate Team', team_id: '75359256-f8b4-4108-8f9c-4dbfb8975548'
      azure_project = Fabricate :azure_project, azure_team: azure_team, project_name: 'FlowClimate', project_id: '19dd7898-d318-4896-8797-afaf2320dcd3'

      demand = Fabricate :demand, external_id: 4, company: company, product: product
      task = Fabricate :task, external_id: 2, demand: demand
      other_task = Fabricate :task, external_id: 3, demand: demand

      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_item).with(demand.external_id, azure_product_config.azure_team.azure_project)).once
      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_item).with(task.external_id, azure_product_config.azure_team.azure_project)).once
      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_item).with(other_task.external_id, azure_product_config.azure_team.azure_project)).once

      expect_any_instance_of(Azure::AzureWorkItemUpdatesAdapter).to(receive(:transitions)).once
      expect(UserNotifierMailer).to receive(:async_activity_finished).once.and_call_original

      described_class.perform_now(demand.external_id, azure_account, azure_project, 'foo@bar.com', 'http://foo.bar')
    end
  end
end
