# frozen_string_literal: true

module Azure
  class AzureWorkItemAdapter < Azure::AzureAdapter
    attr_reader :project_custom_field, :team_custom_field

    def initialize(azure_account)
      super(azure_account)

      @project_custom_field = azure_account.azure_custom_fields.find_by(custom_field_type: :project_name)
      @team_custom_field = azure_account.azure_custom_fields.find_by(custom_field_type: :team_name)
    end

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

      return if project_custom_field.blank? || team_custom_field.blank?

      work_item_response = client.work_item(work_item_id, azure_project.project_id)
      return if work_item_response.blank?

      if work_item_response.respond_to?(:code) && work_item_response.code != 200
        Rails.logger.error("[AzureAPI] Failed to request - #{work_item_response.code}")
      else
        process_work_item(azure_project, company, work_item_response, project_custom_field, team_custom_field)
      end
    end

    private

    def process_work_item(azure_project, company, work_item_response, project_custom_field, team_custom_field)
      work_item_type = work_item_response['fields']['System.WorkItemType']
      product = Product.find_by(name: azure_project.project_name, company: company)

      process_valid_area(work_item_type, product, work_item_response, team_custom_field, company, project_custom_field)
    end

    def process_valid_area(work_item_type, product, work_item_response, team_custom_field, company, project_custom_field)
      if work_item_type.casecmp('epic').zero?
        PortfolioUnit.where(id: work_item_response['fields']['System.Id'], product: product, name: work_item_response['fields']['System.Title'], portfolio_unit_type: :epic).first_or_create
      elsif work_item_type.casecmp('feature')
        team_name = work_item_response['fields'][team_custom_field.custom_field_name]
        team = Team.where('name ILIKE :team_name', team_name: "%#{team_name}%").where(company: company).first
        return if team_name.blank?

        process_issue(company, product, project_custom_field, team, work_item_response)
      end
    end

    def process_issue(company, product, project_custom_field, team, work_item_response)
      project = project(company, project_custom_field, team, work_item_response)
      portfolio_unit = parent(product, work_item_response)

      demand = Demand.where(company: company, team: team, external_id: work_item_response['id'],
                            created_date: work_item_response['fields']['System.CreatedDate'],
                            product: product, project: project, portfolio_unit: portfolio_unit, demand_type: :feature).first_or_create

      demand.update(demand_title: work_item_response['fields']['System.Title'], end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'])
      demand
    end

    def project(company, project_custom_field, team, work_item_response)
      project_name = work_item_response['fields'][project_custom_field.custom_field_name]

      return nil if project_name.blank?

      project = Project.where(name: project_name, company: company, team: team).first_or_create
      project.update(qty_hours: 0, project_type: :outsourcing, status: :executing, start_date: Time.zone.today, end_date: 3.months.from_now, initial_scope: 0, value: 0, hour_value: 0)
      project
    end

    def parent(product, work_item_response)
      parent_id = work_item_response['fields']['System.Parent']
      return nil if parent_id.blank?

      product.portfolio_units.where(id: parent_id)
    end
  end
end
