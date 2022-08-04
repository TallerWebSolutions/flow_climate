# frozen_string_literal: true

module Azure
  class AzureReader
    include Singleton

    def read_team(company, azure_account, work_item_response)
      team_custom_field = azure_account.azure_custom_fields.find_by(custom_field_type: :team_name)
      return company.teams.last if team_custom_field.blank?

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
      initiative = company.initiatives.where('name ILIKE :initiative_name', initiative_name: "%#{initiative_name}%").first

      return company.initiatives.create(name: initiative_name, start_date: Time.zone.today, end_date: 3.months.from_now) if initiative.blank?

      initiative
    end

    def read_card_type(company, work_item_response, item_level)
      type_name = read_tags(work_item_response)&.first
      type = company.work_item_types.where(name: type_name, item_level: item_level).first_or_create

      return type if type.valid?

      company.work_item_types.where(name: 'Default', item_level: item_level).first_or_create
    end

    def read_project(company, customer, team, initiative, azure_account, work_item_response)
      project_custom_fields = azure_account.azure_custom_fields.where(custom_field_type: :project_name)

      project_names = project_custom_fields.map { |custom| work_item_response['fields'][custom.custom_field_name] }

      project_name = project_names.join(' - ')

      project_name = "Other - #{team.name}" if project_name.blank?

      project = company.projects.where(name: project_name).first_or_initialize
      unless project.persisted?
        project.update(team: team, qty_hours: 0, project_type: :outsourcing, status: :executing, start_date: Time.zone.today,
                       end_date: 3.months.from_now, initial_scope: 0, value: 0, hour_value: 0)
      end

      project.update(customers: [customer], initiative: initiative)
      project
    end

    def read_assigned(company, team, demand, work_item_response)
      return if work_item_response['fields']['System.AssignedTo'].blank?

      assigned_name = work_item_response['fields']['System.AssignedTo']['displayName']
      team_member = company.team_members.where('name ILIKE :assigned_name', assigned_name: assigned_name).first_or_initialize

      team_member.update(name: assigned_name.downcase.titleize) unless team_member.persisted?

      build_assignments(demand, team, team_member)
    end

    def read_tags(work_item_response)
      return [] if work_item_response['fields'].blank?

      work_item_response['fields']['System.Tags']&.split(';')&.map(&:strip)
    end

    private

    def build_assignments(demand, team, team_member)
      assignment_start_date = [demand.created_date, demand.commitment_date].compact.max

      membership = team.memberships.where(team_member: team_member).first_or_initialize
      membership.update(start_date: assignment_start_date) unless membership.persisted?

      demand.item_assignments.map(&:destroy)

      assignment = demand.item_assignments.where(membership: membership, start_time: assignment_start_date).first_or_create

      assignment.update(finish_time: demand.end_date) if demand.end_date.present?

      assignment
    end
  end
end
