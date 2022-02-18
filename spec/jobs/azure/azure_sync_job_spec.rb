# frozen_string_literal: true

RSpec.describe Azure::AzureSyncJob do
  describe '.perform' do
    let(:company) { Fabricate :company }
    let(:azure_account) { Fabricate :azure_account, company: company }

    it 'calls the adapters and process the work item' do
      product = Fabricate :product, company: company
      azure_product_config = Fabricate :azure_product_config, product: product
      azure_team = Fabricate :azure_team, azure_product_config: azure_product_config, team_name: 'FlowClimate Team', team_id: '75359256-f8b4-4108-8f9c-4dbfb8975548'
      Fabricate :azure_project, azure_team: azure_team, project_name: 'FlowClimate', project_id: '19dd7898-d318-4896-8797-afaf2320dcd3'

      demand = Fabricate :demand, external_id: 4, company: company
      task = Fabricate :task, demand: demand

      other_demand = Fabricate :demand, external_id: 1, company: company
      other_task = Fabricate :task, demand: other_demand

      valid_demand = Fabricate :demand, external_id: 2, company: company
      deleted_task_in_valid_demand = Fabricate :task, demand: valid_demand, external_id: 100
      not_deleted_task_in_valid_demand = Fabricate :task, demand: valid_demand, external_id: 3

      expect_any_instance_of(Azure::AzureProjectAdapter).to(receive(:products)).once.and_return([product])
      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_items_ids)).and_return([1, 2, 3])
      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_item)).exactly(3).times
      expect_any_instance_of(Azure::AzureWorkItemUpdatesAdapter).to(receive(:transitions).with(other_demand, azure_product_config.azure_team.azure_project.project_id)).once
      expect_any_instance_of(Azure::AzureWorkItemUpdatesAdapter).to(receive(:transitions).with(valid_demand, azure_product_config.azure_team.azure_project.project_id)).once
      expect(UserNotifierMailer).to receive(:async_activity_finished).once.and_call_original

      described_class.perform_now(azure_account, 'bla', 'foo@bar.com')

      expect(demand.reload.discarded_at).not_to be_nil
      expect(task.reload.discarded_at).not_to be_nil
      expect(other_demand.reload.discarded_at).to be_nil
      expect(other_task.reload.discarded_at).to be_nil
      expect(not_deleted_task_in_valid_demand.reload.discarded_at).to be_nil
      expect(deleted_task_in_valid_demand.reload.discarded_at).not_to be_nil
    end
  end
end
