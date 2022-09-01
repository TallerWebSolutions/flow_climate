module Azure
  class AzureItemSyncJob < ApplicationJob
    queue_as :default

    def perform(external_id, azure_account, azure_project, user_email = nil, user_name = nil, demand_url = nil)
      started_time = Time.zone.now
      demand = azure_account.company.demands.where(external_id: external_id).first_or_initialize

      azure_azure_work_item_adapter = Azure::AzureWorkItemAdapter.new(azure_account)

      azure_azure_work_item_adapter.work_item(external_id, azure_project)

      if demand.persisted?
        demand.tasks.each { |task| azure_azure_work_item_adapter.work_item(task.external_id, azure_project) }
      end

      Azure::AzureWorkItemUpdatesAdapter.new(azure_account).transitions(demand, azure_project.project_id)

      finished_time = Time.zone.now

      if user_email.present?
        UserNotifierMailer.async_activity_finished(user_email,
                                                   user_name,
                                                   Demand.model_name.human.downcase,
                                                   azure_account.id,
                                                   started_time,
                                                   finished_time,
                                                   demand_url).deliver
      end
    end
  end
end
