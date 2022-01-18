# frozen_string_literal: true

module Azure
  class AzureSyncJob < ApplicationJob
    queue_as :demand_update

    def perform(azure_account)
      products = Azure::AzureProjectAdapter.new(azure_account).products
      work_item_adapter = Azure::AzureWorkItemAdapter.new(azure_account)

      products.each do |product|
        azure_product_config = product.azure_product_config
        work_items_ids = work_item_adapter.work_items_ids(azure_product_config)

        Rails.logger.info("found #{work_items_ids.count} work items")

        work_items_ids.sort.uniq.each do |id|
          next if azure_product_config.azure_team&.azure_project.blank?

          work_item_adapter.work_item(id, azure_product_config.azure_team.azure_project)
        end
      end
    end
  end
end
