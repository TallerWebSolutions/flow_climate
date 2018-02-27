# frozen_string_literal: true

class PipefyReader
  include Singleton

  def process_card(team, card_response)
    response_data = card_response['data']
    name_in_pipefy = read_project_name_from_pipefy_data(response_data)
    return if name_in_pipefy.blank?

    project = Project.all.select { |p| p.full_name.casecmp(name_in_pipefy.downcase).zero? }.first
    return if project.blank?

    demand = create_demand(project, response_data)
    read_phases(response_data, demand)
    update_project_results(demand, team)
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
    url = response_data.try(:[], 'card').try(:[], 'url')
    DemandsRepository.instance.create_or_update_demand(project, demand_id, read_demand_type(response_data), read_class_of_service(response_data), url)
  end

  def read_phases(response_data, demand)
    response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
      create_transition_for_phase(phase, demand)
    end
  end

  def create_transition_for_phase(phase, demand)
    phase_id = phase['phase']['id']
    stage = Stage.where(integration_id: phase_id).first
    return if stage.blank? || demand.blank?
    DemandTransition.create(stage: stage, demand: demand, last_time_in: phase['firstTimeIn'], last_time_out: phase['lastTimeOut'])
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

  def update_project_results(demand, team)
    first_transition = demand.demand_transitions.order(:last_time_in).first
    return if first_transition.blank?

    result_date = define_result_date(demand, first_transition)
    new_result = ProjectResultsRepository.instance.create_project_result(demand.project, team, result_date)

    update_effort(demand)

    ProjectResultsRepository.instance.update_previous_and_current_demand_results(demand.project, demand.project_result, new_result)
  end

  def define_result_date(demand, first_transition)
    end_transition = demand.demand_transitions.joins(:stage).where('stages.end_point = true').first
    commitment_transition = demand.demand_transitions.joins(:stage).where('stages.commitment_point = true').first

    end_transition&.last_time_in || commitment_transition&.last_time_in || first_transition&.last_time_in
  end

  def update_effort(demand)
    effort_transition = demand.demand_transitions.joins(:stage).where('stages.compute_effort = true').first
    return if effort_transition.blank?
    effort = DemandService.instance.compute_effort_for_dates(effort_transition.last_time_in, effort_transition.last_time_out)
    demand.update(effort: effort)
  end
end
