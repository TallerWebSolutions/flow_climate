# frozen_string_literal: true

module Azure
  class AzureWorkItemAdapter < Azure::AzureAdapter
    attr_reader :project_custom_field, :team_custom_field

    def work_items_ids(azure_product_config)
      work_items_ids = []
      items_ids_response = client.work_items_ids(azure_product_config)

      if items_ids_response.respond_to?(:code) && items_ids_response.code != 200
        Rails.logger.error("[AzureAPI] Failed to request - #{items_ids_response.code}")
      else
        items_ids = items_ids_response
        work_items_ids = items_ids['workItems'].map { |item| item['id'] }
      end

      work_items_ids
    end

    def work_item(work_item_id, azure_project)
      company = @azure_account.company

      work_item_response = client.work_item(work_item_id, azure_project.project_id)
      return if work_item_response.blank?

      if work_item_response.respond_to?(:code) && work_item_response.code != 200
        Rails.logger.error("[AzureAPI] Failed to request - #{work_item_response.code}")
      else
        read_work_item(company, azure_project, work_item_response.parsed_response)
      end
    end

    private

    def read_work_item(company, azure_project, work_item_response)
      product = Product.find_by(name: azure_project.project_name, company: company)

      process_valid_area(company, product, azure_project, work_item_response)
    end

    def process_valid_area(company, product, azure_project, work_item_response)
      customer = Azure::AzureReader.instance.read_customer(company, work_item_response)
      team = Azure::AzureReader.instance.read_team(company, @azure_account, work_item_response)
      initiative = Azure::AzureReader.instance.read_initiative(company, work_item_response)
      project = Azure::AzureReader.instance.read_project(company, customer, team, initiative, @azure_account, work_item_response)

      work_item_type = work_item_response['fields']['System.WorkItemType']
      if work_item_type.casecmp('epic').zero?
        read_epic(product, work_item_response)
      elsif work_item_type.casecmp('feature').zero?
        read_feature(customer, product, project, team, work_item_response)
      elsif work_item_type.casecmp('user story').zero?
        read_user_story(customer, product, project, team, azure_project, work_item_response)
      end
    end

    def read_feature(customer, product, project, team, work_item_response)
      company = product.company

      demand = Demand.with_discarded.where(external_id: work_item_response['id']).first_or_initialize

      demand_type = AzureReader.instance.read_card_type(project.company, work_item_response, :demand)

      demand.update(company: company, team: team, customer: customer,
                    demand_title: work_item_response['fields']['System.Title'].strip,
                    created_date: work_item_response['fields']['System.CreatedDate'],
                    end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'],
                    product: product, project: project, work_item_type: demand_type,
                    discarded_at: nil)

      demand
    end

    def read_epic(product, work_item_response)
      product.portfolio_units.where(name: work_item_response['fields']['System.Title'], portfolio_unit_type: :epic).first_or_create
    end

    def read_user_story(customer, product, project, team, azure_project, work_item_response)
      demand = read_task_parent(customer, product, project, team, azure_project, work_item_response)

      task_type = AzureReader.instance.read_card_type(project.company, work_item_response, :task)

      task = Task.with_discarded.where(external_id: work_item_response['id']).first_or_initialize
      task.update(title: work_item_response['fields']['System.Title'], created_date: work_item_response['fields']['System.CreatedDate'],
                  end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'], demand: demand,
                  work_item_type: task_type, discarded_at: nil)

      task
    end

    def read_task_parent(customer, product, project, team, azure_project, work_item_response)
      parent_id = work_item_response['fields']['System.Parent']
      demand = Demand.find_by(company: project.company, external_id: parent_id)

      return demand if demand.present?

      parent_response = client.work_item(parent_id, azure_project.project_id)
      return if parent_response.blank? || parent_response.code != 200

      read_feature(customer, product, project, team, parent_response.parsed_response)
    end
  end
end
