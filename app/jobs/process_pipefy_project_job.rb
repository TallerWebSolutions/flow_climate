# frozen_string_literal: true

class ProcessPipefyProjectJob < ApplicationJob
  def perform(project_id)
    project = Project.find_by(id: project_id)
    return if project.pipefy_config.blank?
    project.stages.each do |stage|
      ids_cards_in_stage = Pipefy::PipefyReader.instance.read_phase(stage.integration_id)
      process_cards_in_pipefy_and_update_informations!(project, project.pipefy_config.team, ids_cards_in_stage)
    end
    process_project_demands(project)
    project.project_results.map(&:compute_flow_metrics!)
  end

  private

  def process_project_demands(project)
    project.demands.joins(:demand_transitions).uniq.each do |demand|
      pipefy_card_response = Pipefy::PipefyApiService.request_card_details(demand.demand_id)
      next if pipefy_card_response.code != 200
      card_response = JSON.parse(pipefy_card_response.body)
      Pipefy::PipefyCardResponseReader.instance.update_card!(project, project.pipefy_config.team, demand, card_response)
    end
  end

  def process_cards_in_pipefy_and_update_informations!(project, team, cards_to_check)
    cards_to_check.each do |card_id|
      pipefy_card_response = Pipefy::PipefyApiService.request_card_details(card_id)
      next if pipefy_card_response.code != 200
      card_response = JSON.parse(pipefy_card_response.body)
      project_name_in_pipefy = Pipefy::PipefyReader.instance.read_project_name_from_pipefy_data(card_response['data'])
      updated_project = ProjectsRepository.instance.search_project_by_full_name(project_name_in_pipefy) || project
      known_demand = project.demands.find_by(demand_id: card_id)
      Pipefy::PipefyCardResponseReader.instance.create_card!(updated_project, team, card_response) || known_demand
    end
  end
end
