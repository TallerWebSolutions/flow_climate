module Azure
  class AzureItemSyncJob < ApplicationJob
    queue_as :demand_update

    def perform(demand_id, azure_account, user_email, user_name, demand_url)
      started_time = Time.zone.now
      demand = Demand.find_by(id: demand_id)

      if demand.present?
        azure_product_config = demand.product.azure_product_config
        azure_azure_work_item_adapter = Azure::AzureWorkItemAdapter.new(azure_account)

        azure_azure_work_item_adapter.work_item(demand.external_id, azure_product_config.azure_team.azure_project)

        demand.tasks.each do |task|
          azure_azure_work_item_adapter.work_item(task.external_id, azure_product_config.azure_team.azure_project)
        end

        Azure::AzureWorkItemUpdatesAdapter.new(azure_account).transitions(demand, azure_product_config.azure_team.azure_project.project_id)

        finished_time = Time.zone.now

        UserNotifierMailer.async_activity_finished(user_email, user_name, Demand.model_name.human.downcase, azure_account.id, started_time, finished_time, demand_url).deliver
      end
    end
  end
end
