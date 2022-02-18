# frozen_string_literal: true

module Azure
  class AzureSyncJob < ApplicationJob
    queue_as :demand_update

    def perform(azure_account, user_email, user_name)
      started_time = Time.zone.now
      products = Azure::AzureProjectAdapter.new(azure_account).products
      work_item_adapter = Azure::AzureWorkItemAdapter.new(azure_account)
      azure_work_item_update = Azure::AzureWorkItemUpdatesAdapter.new(azure_account)

      products.each do |product|
        azure_product_config = product.azure_product_config
        work_items_ids = work_item_adapter.work_items_ids(azure_product_config)

        remove_deleted_items(azure_account.company, work_items_ids)

        Rails.logger.info("[AzureAPI] found #{work_items_ids.count} work items")

        work_items_ids.sort.uniq.each do |id|
          next if azure_product_config.azure_team&.azure_project.blank?

          work_item_adapter.work_item(id, azure_product_config.azure_team.azure_project)

          demand = Demand.find_by(external_id: id)
          azure_work_item_update.transitions(demand, azure_product_config.azure_team.azure_project.project_id) if demand.present?
        end
      end

      finished_time = Time.zone.now

      UserNotifierMailer.async_activity_finished(user_email, user_name, AzureAccount.model_name.human.downcase, azure_account.id, started_time, finished_time, '').deliver
    end

    private

    def remove_deleted_items(company, azure_work_items_ids)
      company.demands.where.not(external_id: azure_work_items_ids).map(&:discard)
      company.tasks.where.not(external_id: azure_work_items_ids).map(&:discard)
    end
  end
end
