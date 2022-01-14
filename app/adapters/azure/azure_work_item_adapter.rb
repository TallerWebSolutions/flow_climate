# frozen_string_literal: true

module Azure
  class AzureWorkItemAdapter < Azure::AzureAdapter
    def work_items_ids(azure_product_config)
      work_items_ids = []
      items_ids_response = client.work_items_ids(azure_product_config)

      if items_ids_response.respond_to?(:code) && items_ids_response.code != 200
        Rails.logger.error("[AzureAPI] Failed to request - #{items_ids_response.code}")
      else
        items_ids = JSON.parse(items_ids_response)
        work_items_ids = items_ids['workItems'].map { |item| item['id'] }
      end

      work_items_ids
    end

    def work_item(work_item_ids, azure_project)
      company = @azure_account.company
      project_custom_field = azure_account.azure_custom_fields.find_by(custom_field_type: :project_name)

      return if project_custom_field.blank?

      work_item_ids.each do |id|
        work_item_response = client.work_item(id, azure_project.project_id)
        if work_item_response.respond_to?(:code) && work_item_response.code != 200
          Rails.logger.error("[AzureAPI] Failed to request - #{work_item_response.code}")
        else
          work_item = JSON.parse(work_item_response)
          process_work_item(azure_project, company, work_item, project_custom_field)
        end
      end
    end

    private

    def process_work_item(azure_project, company, work_item, project_custom_field)
      work_item_type = work_item['fields']['System.WorkItemType']
      product = Product.find_by(name: azure_project.project_name, company: company) # PMO Marketing E2E
      project = Project.find_by(name: work_item['fields'][project_custom_field.custom_field_name], company: company)

      if work_item_type == 'Issue'
        Demand.where(company: company, team: project.team, external_id: work_item['id'], created_date: work_item['fields']['System.CreatedDate'],
                     end_date: work_item['fields']['Microsoft.VSTS.Common.ClosedDate'], product: product, project: project, demand_type: :feature).first_or_create
      else
        PortfolioUnit.where(product: product, name: work_item['fields']['System.CreatedDate'], portfolio_unit_type: :epic).first_or_create
      end
    end
  end
end
