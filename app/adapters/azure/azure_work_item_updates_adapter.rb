# frozen_string_literal: true

module Azure
  class AzureWorkItemUpdatesAdapter < Azure::AzureAdapter
    def transitions(demand, azure_project_id)
      work_item_updates_hash = client.work_item_updates(demand.external_id, azure_project_id)

      transitions = []
      if work_item_updates_hash.respond_to?(:code) && work_item_updates_hash.code != 200
        Rails.logger.error("[AzureAPI] Failed to request azure item updates for ##{demand.external_id} - Reason: #{work_item_updates_hash.code}")
      else
        transitions = process_valid_item_updates_response(demand, work_item_updates_hash)
      end

      remove_not_read_transitions(demand, transitions)
    end

    private

    def process_valid_item_updates_response(demand, work_item_updates_hash)
      transitions = []

      work_item_updates_hash['value'].sort_by { |value| value['revisedDate'] }.each do |azure_json_value|
        next if azure_json_value['fields'].blank? || azure_json_value['fields']['System.State'].blank?

        demand_transition = read_transition(azure_json_value, demand)
        transitions << demand_transition
      end

      transitions
    end

    def remove_not_read_transitions(demand, transitions)
      demand.demand_transitions.where.not(id: transitions.map(&:id)).map(&:destroy)
      transitions.uniq
    end

    # OPTIMIZE: move all reader methods to an AzureReader
    def read_transition(azure_json_value, demand)
      to_stage_name = azure_json_value['fields']['System.State']['newValue']
      company = azure_account.company
      team_member = read_team_member(azure_json_value, company)

      to_date = azure_json_value['fields']['System.ChangedDate']['newValue']
      read_from_transition(azure_json_value, company, demand, to_date)

      to_stage = read_stage(company, demand, to_stage_name)
      demand_transition = DemandTransition.where(demand: demand, stage: to_stage, team_member: team_member, last_time_in: to_date).first_or_initialize
      demand_transition.save

      if to_stage.trashcan?
        demand.discard_with_date(to_date)
      else
        demand.undiscard
      end

      demand_transition
    end

    def read_stage(company, demand, to_stage_name)
      to_stage = Stage.where(company: company, integration_id: azure_account.id).where('name ILIKE :stage_name', stage_name: to_stage_name).first_or_initialize
      to_stage.name = to_stage_name.titleize
      to_stage.save
      to_stage.projects << demand.project unless demand.project.blank? || to_stage.projects.include?(demand.project)
      to_stage
    end

    def read_from_transition(azure_json_value, company, demand, to_date)
      from_stage_name = azure_json_value['fields']['System.State']['oldValue']
      return if from_stage_name.blank?

      from_stage = Stage.where(company: company, integration_id: azure_account.id).where('name ILIKE :stage_name', stage_name: from_stage_name).first
      from_transition = DemandTransition.where(demand: demand, stage: from_stage).last
      from_transition.update(last_time_out: to_date)
    end

    def read_team_member(azure_json_value, company)
      team_member = TeamMember.where(company: company, name: azure_json_value['revisedBy']['displayName']).first_or_create
      user = azure_account.company.users.find_by(email: azure_json_value['revisedBy']['uniqueName'])
      team_member.update(user: user)
      team_member
    end
  end
end
