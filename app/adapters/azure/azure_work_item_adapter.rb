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
        read_work_item(azure_project, company, work_item_response.parsed_response, project_custom_field, team_custom_field)
      end
    end

    private

    def read_work_item(azure_project, company, work_item_response, project_custom_field, team_custom_field)
      product = Product.find_by(name: azure_project.project_name, company: company)

      process_valid_area(product, work_item_response, team_custom_field, azure_project, company, project_custom_field)
    end

    def process_valid_area(product, work_item_response, team_custom_field, azure_project, company, project_custom_field)
      team_name = work_item_response['fields'][team_custom_field.custom_field_name]
      return if team_name.blank?

      team = Team.where('name ILIKE :team_name', team_name: "%#{team_name}%").where(company: company).first

      work_item_type = work_item_response['fields']['System.WorkItemType']
      if work_item_type.casecmp('epic').zero?
        read_epic(product, project_custom_field, team, work_item_response)
      elsif work_item_type.casecmp('feature').zero?
        read_feature(product, project_custom_field, team, azure_project, work_item_response)
      end
    end

    def read_feature(product, project_custom_field, team, azure_project, work_item_response)
      demand = feature_parent(product, project_custom_field, team, azure_project, work_item_response)

      task = Task.where(demand: demand, external_id: work_item_response['id']).first_or_initialize
      task.update(title: work_item_response['fields']['System.Title'], created_date: work_item_response['fields']['System.CreatedDate'],
                  end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'], discarded_at: nil)
    end

    def feature_parent(product, project_custom_field, team, azure_project, work_item_response)
      parent_response = client.work_item(work_item_response['fields']['System.Parent'], azure_project.project_id)
      return if parent_response.blank? || parent_response.code != 200

      demand = Demand.with_discarded.find_by(external_id: parent_response.parsed_response['id'])

      return read_epic(product, project_custom_field, team, work_item_response) if demand.blank?

      demand
    end

    def read_epic(product, project_custom_field, team, work_item_response)
      company = product.company
      project = project(company, project_custom_field, team, work_item_response)

      demand = Demand.with_discarded.where(company: company, team: team, external_id: work_item_response['id']).first_or_initialize

      demand.update(demand_title: work_item_response['fields']['System.Title'].strip,
                    created_date: work_item_response['fields']['System.CreatedDate'],
                    end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'],
                    product: product, project: project, demand_type: :feature, discarded_at: nil)
      demand
    end

    def project(company, project_custom_field, team, work_item_response)
      project_name = work_item_response['fields'][project_custom_field.custom_field_name]

      project_name = work_item_response['fields']['Custom.TargetQuarter'] + work_item_response['fields']['Custom.Year'].slice(-2, 2) if project_name.blank?

      project_name += " - #{team.name}"

      project = Project.where(name: project_name, company: company, team: team).first_or_initialize
      unless project.persisted?
        project.update(qty_hours: 0, project_type: :outsourcing, status: :executing, start_date: Time.zone.today,
                       end_date: 3.months.from_now, initial_scope: 0, value: 0, hour_value: 0)
      end
      project
    end
  end
end
