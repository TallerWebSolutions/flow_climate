# frozen_string_literal: true

class PipefyReader
  include Singleton

  def process_card(team, card_response)
    response_data = card_response['data']
    name_in_pipefy = read_project_name_from_pipefy_data(response_data)
    return if name_in_pipefy.blank?

    project = ProjectsRepository.instance.search_project_by_full_name(name_in_pipefy)
    return if project.blank?

    demand = create_demand(project, response_data)
    read_phases_transitions(demand, response_data)
    demand.update_effort!
    ProjectResultsRepository.instance.create_empty_project_result_using_transition(demand, team)
    project
  end

  private

  def read_project_name_from_pipefy_data(response_data)
    project_pipefy_name = ''
    response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
      next unless field['name'].casecmp('project').zero?
      project_pipefy_name = field['value']
    end
    project_pipefy_name
  end

  def create_demand(project, response_data)
    demand_id = response_data.try(:[], 'card').try(:[], 'id')
    assignees_count = response_data.try(:[], 'card').try(:[], 'assignees')&.uniq&.count || 1
    url = response_data.try(:[], 'card').try(:[], 'url')

    demand = Demand.where(project: project, demand_id: demand_id).first_or_initialize
    demand.update(demand_type: read_demand_type(response_data), class_of_service: read_class_of_service(response_data), assignees_count: assignees_count, url: url)
    demand
  end

  def read_phases_transitions(demand, response_data)
    response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
      create_transition_for_phase_and_demand(phase, demand)
    end
  end

  def create_transition_for_phase_and_demand(phase, demand)
    phase_id = phase['phase']['id']
    stage = Stage.where(integration_id: phase_id).first
    return if stage.blank? || demand.blank?
    last_time_out = nil
    last_time_out = Time.iso8601(phase['lastTimeOut']) if phase['lastTimeOut'].present?
    DemandTransition.where(stage: stage, demand: demand, last_time_in: Time.iso8601(phase['firstTimeIn']), last_time_out: last_time_out).first_or_create
  end

  def read_demand_type(response_data)
    demand_type_in_response = :feature
    response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
      next unless field['name'].casecmp('type').zero?
      demand_type_in_response = if field['value'].casecmp('bug').zero?
                                  :bug
                                elsif field['value'].casecmp('nova funcionalidade').zero?
                                  :feature
                                else
                                  :chore
                                end
    end
    demand_type_in_response
  end

  def read_class_of_service(response_data)
    demand_class_of_service = :standard
    response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
      next unless field['name'].casecmp('class of service').zero?
      demand_class_of_service = if field['value'].casecmp('expedição').zero?
                                  :expedite
                                elsif field['value'].casecmp('data fixa').zero?
                                  :fixed_date
                                elsif field['value'].casecmp('intangível').zero?
                                  :intangible
                                else
                                  :standard
                                end
    end
    demand_class_of_service
  end

  def read_assignees_count(response_data); end
end
