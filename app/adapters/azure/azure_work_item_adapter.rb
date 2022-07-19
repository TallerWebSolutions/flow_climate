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
      product = company.products.find_by(name: azure_project.project_name)

      process_valid_area(product, azure_project, work_item_response)
    end

    def process_valid_area(product, azure_project, work_item_response)
      company = product.company

      work_item_type = work_item_response['fields']['System.WorkItemType']
      if work_item_type.casecmp('epic').zero?
        read_epic(product, work_item_response['fields']['System.Title'])
      elsif work_item_type.casecmp('feature').zero?
        read_feature(company, product, azure_project, work_item_response)
      elsif work_item_type.casecmp('user story').zero?
        read_user_story(product, azure_project, work_item_response)
      end
    end

    def read_epic(product, unit_name)
      controlled_name = unit_name.downcase.strip
      unit = product.portfolio_units.where('name ILIKE :name', name: controlled_name).where(portfolio_unit_type: :epic).first_or_initialize
      return unit if unit.persisted?

      unit.update(name: controlled_name.strip.titleize)
      unit
    end

    def read_feature(company, product, azure_project, work_item_response)
      parent = read_feature_parent(product, azure_project, work_item_response)
      customer = Azure::AzureReader.instance.read_customer(company, work_item_response)
      team = Azure::AzureReader.instance.read_team(company, @azure_account, work_item_response)
      initiative = Azure::AzureReader.instance.read_initiative(company, work_item_response)
      project = Azure::AzureReader.instance.read_project(company, customer, team, initiative, @azure_account, work_item_response)
      work_item_type = AzureReader.instance.read_card_type(company, work_item_response, :demand)

      save_demand(company, customer, parent, product, project, team, work_item_response, work_item_type)
    end

    def save_demand(company, customer, parent, product, project, team, work_item_response, work_item_type)
      demand = Demand.with_discarded.where(external_id: work_item_response['id']).first_or_initialize

      demand.update(company: company, team: team, customer: customer, demand_title: demand_title(work_item_response),
                    created_date: created_date(work_item_response), end_date: end_date(work_item_response),
                    product: product, project: project, work_item_type: work_item_type, portfolio_unit: parent,
                    discarded_at: nil)

      demand
    end

    def read_user_story(product, azure_project, work_item_response)
      demand = read_task_parent(product, azure_project, work_item_response)

      task_type = AzureReader.instance.read_card_type(product.company, work_item_response, :task)

      task = Task.with_discarded.where(external_id: work_item_response['id']).first_or_initialize
      task.update(title: work_item_response['fields']['System.Title'], created_date: created_date(work_item_response),
                  end_date: end_date(work_item_response), demand: demand,
                  work_item_type: task_type, discarded_at: nil)

      task
    end

    def read_task_parent(product, azure_project, work_item_response)
      parent_id = work_item_response['fields']['System.Parent']
      company = product.company
      demand = company.demands.find_by(external_id: parent_id)

      return demand if demand.present?

      parent_response = client.work_item(parent_id, azure_project.project_id)
      return if parent_response.blank? || parent_response.code != 200

      read_feature(company, product, azure_project, parent_response.parsed_response)
    end

    def read_feature_parent(product, azure_project, work_item_response)
      custom_epic_field = azure_project.azure_team.azure_product_config.azure_account.azure_custom_fields.epic_name.first

      custom_epic_name = work_item_response['fields'][custom_epic_field.custom_field_name] if custom_epic_field.present?

      return read_epic(product, custom_epic_name) if custom_epic_name.present?

      parent_id = work_item_response['fields']['System.Parent']
      company = product.company
      epic = company.portfolio_units.find_by(external_id: parent_id)

      return epic if epic.present?

      read_parent_from_azure(azure_project, parent_id, product)
    end

    def read_parent_from_azure(azure_project, parent_id, product)
      parent_response = client.work_item(parent_id, azure_project.project_id)
      return if parent_response.blank? || parent_response.code != 200

      parsed_parent_response = parent_response.parsed_response
      read_epic(product, parsed_parent_response['fields']['System.Title'])
    end

    def end_date(work_item_response)
      work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate']
    end

    def created_date(work_item_response)
      work_item_response['fields']['System.CreatedDate']
    end

    def demand_title(work_item_response)
      work_item_response['fields']['System.Title'].strip
    end
  end
end
