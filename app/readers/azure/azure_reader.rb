# frozen_string_literal: true

module Azure
  class AzureReader
    include Singleton

    def read_team(company, azure_account, work_item_response)
      team_custom_field = azure_account.azure_custom_fields.find_by(custom_field_type: :team_name)
      return if team_custom_field.blank?

      team_name = work_item_response['fields'][team_custom_field.custom_field_name] || 'Default Team'
      team = company.teams.where('name ILIKE :team_name', team_name: "%#{team_name}%").first

      return company.teams.create(name: team_name) if team.blank?

      team
    end

    def read_customer(company, work_item_response)
      customer_custom_field = 'Custom.Category'
      customer_name = work_item_response['fields'][customer_custom_field] || 'Default Customer'
      customer = company.customers.where('name ILIKE :customer_name', customer_name: "%#{customer_name}%").first
      return company.customers.create(name: customer_name) if customer.blank?

      customer
    end

    def read_initiative(company, work_item_response)
      quarter_custom_field = 'Custom.TargetQuarter'
      year_custom_field = 'Custom.Year'

      quarter = work_item_response['fields'][quarter_custom_field]
      year = work_item_response['fields'][year_custom_field]

      return if quarter.blank? || year.blank?

      initiative_name = "#{quarter}/#{year}"
      initiative = company.initiatives.where('name ILIKE :team_name', team_name: "%#{initiative_name}%").first

      return company.initiatives.create(name: initiative_name, start_date: Time.zone.today, end_date: 3.months.from_now)

      initiative
    end

    def read_card_type(company, work_item_response, item_level)
      type = company.work_item_types.where(name: work_item_response['fields']['System.Tags'], item_level: item_level).first_or_create

      return type if type.valid?

      company.work_item_types.where(name: 'Default', item_level: item_level).first_or_create
    end

    def read_project(company, customer, team, initiative, azure_account, work_item_response)
      project_custom_field = azure_account.azure_custom_fields.find_by(custom_field_type: :project_name)
      project_name = work_item_response['fields'][project_custom_field.custom_field_name]

      project_name = 'Other' if project_name.blank?

      project_name += " - #{team.name}"

      project = company.projects.where(name: project_name, team: team).first_or_initialize
      unless project.persisted?
        project.update(qty_hours: 0, project_type: :outsourcing, status: :executing, start_date: Time.zone.today,
                       end_date: 3.months.from_now, initial_scope: 0, value: 0, hour_value: 0)
      end

      project.update(customers: [customer], initiative: initiative)
      project
    end
  end
end
