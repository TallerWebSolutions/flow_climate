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
        read_work_item(company, azure_project, work_item_response.parsed_response)
      end
    end

    private

    def read_work_item(company, azure_project, work_item_response)
      product = Product.find_by(name: azure_project.project_name, company: company)

      process_valid_area(company, product, azure_project, work_item_response)
    end

    def process_valid_area(company, product, azure_project, work_item_response)
      team_name = work_item_response['fields'][@team_custom_field.custom_field_name]
      return if team_name.blank?

      team = read_team(company, team_name)
      project = read_project(company, team, work_item_response)

      work_item_type = work_item_response['fields']['System.WorkItemType']
      if work_item_type.casecmp('epic').zero?
        read_epic(product, work_item_response)
      elsif work_item_type.casecmp('feature').zero?
        read_feature(product, project, team, work_item_response)
      elsif work_item_type.casecmp('user story').zero?
        read_user_story(product, project, team, azure_project, work_item_response)
      end
    end

    def read_feature(product, project, team, work_item_response)
      company = product.company

      demand = Demand.with_discarded.where(external_id: work_item_response['id']).first_or_initialize

      demand_type = read_card_type(project.company, work_item_response, :demand)

      demand.update(company: company, team: team, demand_title: work_item_response['fields']['System.Title'].strip,
                    created_date: work_item_response['fields']['System.CreatedDate'],
                    end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'],
                    product: product, project: project, work_item_type: demand_type,
                    discarded_at: nil)
      demand
    end

    def read_epic(product, work_item_response)
      product.portfolio_units.where(name: work_item_response['fields']['System.Title'], portfolio_unit_type: :epic).first_or_create
    end

    def read_user_story(product, project, team, azure_project, work_item_response)
      demand = read_task_parent(product, project, team, azure_project, work_item_response)

      task_type = read_card_type(project.company, work_item_response, :task)

      task = Task.with_discarded.where(external_id: work_item_response['id']).first_or_initialize
      task.update(title: work_item_response['fields']['System.Title'], created_date: work_item_response['fields']['System.CreatedDate'],
                  end_date: work_item_response['fields']['Microsoft.VSTS.Common.ClosedDate'], demand: demand,
                  work_item_type: task_type, discarded_at: nil)

      task
    end

    def read_card_type(company, work_item_response, item_level)
      type = company.work_item_types.where(name: work_item_response['fields']['System.Tags'], item_level: item_level).first_or_create

      return type if type.valid?

      company.work_item_types.where(name: 'Default', item_level: item_level).first_or_create
    end

    def read_task_parent(product, project, team, azure_project, work_item_response)
      parent_id = work_item_response['fields']['System.Parent']
      demand = Demand.find_by(company: project.company, external_id: parent_id)

      return demand if demand.present?

      parent_response = client.work_item(parent_id, azure_project.project_id)
      return if parent_response.blank? || parent_response.code != 200

      read_feature(product, project, team, parent_response.parsed_response)
    end

    def read_team(company, team_name)
      team = company.teams.where('name ILIKE :team_name', team_name: "%#{team_name}%").first
      team = company.teams.create(name: team_name) if team.blank?
      team
    end

    def read_project(company, team, work_item_response)
      project_name = work_item_response['fields'][@project_custom_field.custom_field_name]

      project_name = 'Other' if project_name.blank?

      project_name += " - #{team.name}"

      project = company.projects.where(name: project_name, team: team).first_or_initialize
      unless project.persisted?
        project.update(qty_hours: 0, project_type: :outsourcing, status: :executing, start_date: Time.zone.today,
                       end_date: 3.months.from_now, initial_scope: 0, value: 0, hour_value: 0)
      end
      project
    end
  end
end
