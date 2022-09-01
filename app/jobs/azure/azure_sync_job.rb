# frozen_string_literal: true

module Azure
  class AzureSyncJob < ApplicationJob
    queue_as :default

    def perform(azure_account, user_email, user_name)
      started_time = Time.zone.now
      products = Azure::AzureProjectAdapter.new(azure_account).products
      work_item_adapter = Azure::AzureWorkItemAdapter.new(azure_account)

      products.each do |product|
        azure_product_config = product.azure_product_config
        work_items_ids = work_item_adapter.work_items_ids(azure_product_config)

        next if azure_product_config.azure_team&.azure_project.blank?

        remove_deleted_items(azure_account.company, work_items_ids)

        items_count = work_items_ids.count
        Rails.logger.info("[AzureAPI] found #{items_count} work items")

        work_items_ids.sort.uniq.each_with_index do |id, index|
          Rails.logger.info("[AzureAPI] processing #{index} of #{items_count}")

          Azure::AzureItemSyncJob.perform_later(id, azure_account, azure_product_config.azure_team.azure_project)
        end
      end

      finished_time = Time.zone.now

      UserNotifierMailer.async_activity_finished(user_email, user_name, AzureAccount.model_name.human.downcase, azure_account.id, started_time, finished_time, '').deliver if user_email.present?
    end

    private

    def remove_deleted_items(company, azure_work_items_ids)
      company.tasks.where.not(external_id: azure_work_items_ids).map(&:destroy)
      company.demands.where.not(external_id: azure_work_items_ids).map(&:destroy)
    end
  end
end
