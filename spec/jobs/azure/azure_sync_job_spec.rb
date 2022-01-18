# frozen_string_literal: true

RSpec.describe Azure::AzureSyncJob do
  describe '.perform' do
    let(:company) { Fabricate :company }
    let(:azure_account) { Fabricate :azure_account, company: company }

    it 'calls the adapters and process the work item' do
      product = Fabricate :product
      azure_product_config = Fabricate :azure_product_config, product: product
      azure_team = Fabricate :azure_team, azure_product_config: azure_product_config, team_name: 'FlowClimate Team', team_id: '75359256-f8b4-4108-8f9c-4dbfb8975548'
      Fabricate :azure_project, azure_team: azure_team, project_name: 'FlowClimate', project_id: '19dd7898-d318-4896-8797-afaf2320dcd3'

      expect_any_instance_of(Azure::AzureProjectAdapter).to(receive(:products)).once.and_return([product])
      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_items_ids)).and_return([1, 2])
      expect_any_instance_of(Azure::AzureWorkItemAdapter).to(receive(:work_item)).twice
      expect(UserNotifierMailer).to receive(:async_activity_finished).once.and_call_original

      described_class.perform_now(azure_account, 'bla', 'foo@bar.com')
    end
  end
end
