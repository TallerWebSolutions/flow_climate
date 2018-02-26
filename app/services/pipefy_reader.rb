# frozen_string_literal: true

class PipefyReader
  include Singleton

  def process_card(card_response)
    response_data = card_response['data']
    pipe_id = response_data.try(:[], 'card').try(:[], 'pipe').try(:[], 'id')
    pipefy_configs = PipefyConfig.where(pipe_id: pipe_id)
    return if pipefy_configs.blank?

    project = pipefy_configs.first.project
    team = pipefy_configs.first.team

    demand = create_demand(project, response_data)
    read_phases(response_data, demand)
    update_project_results(demand, team)
  end

  private

  def create_demand(project, response_data)
    demand_id = response_data.try(:[], 'card').try(:[], 'id')
    url = response_data.try(:[], 'card').try(:[], 'url')
    DemandsRepository.instance.create_or_update_demand(project, demand_id, demand_type(response_data), url)
  end

  def read_phases(response_data, demand)
    response_data.try(:[], 'card').try(:[], 'phases_history')&.each do |phase|
      create_transition_for_phase(phase, demand)
    end
  end

  def create_transition_for_phase(phase, demand)
    phase_id = phase['phase']['id']
    stage = Stage.where(integration_id: phase_id).first
    return if stage.blank?
    DemandTransition.create(stage: stage, demand: demand, last_time_in: phase['lastTimeIn'], last_time_out: phase['lastTimeOut'])
  end

  def demand_type(response_data)
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
