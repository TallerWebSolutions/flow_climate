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
    demands_id_to_delete = []
    project.demands.joins(:demand_transitions).uniq.each do |demand|
      pipefy_card_response = Pipefy::PipefyApiService.request_card_details(demand.demand_id)
      next if pipefy_card_response.code != 200
      process_card_response!(demand, demands_id_to_delete, pipefy_card_response, project)
    end
    demands_id_to_delete.each { |id| DemandsRepository.instance.full_demand_destroy!(Demand.find(id)) }
  end

  def process_card_response!(demand, demands_id_to_delete, pipefy_card_response, project)
    card_response = JSON.parse(pipefy_card_response.body)
    if card_response['data']['card'].blank?
      demands_id_to_delete << demand.id
    else
      Pipefy::PipefyCardResponseReader.instance.process_card_response!(project.pipefy_config.team, demand, card_response)
    end
  end

  def process_cards_in_pipefy_and_update_informations!(project, team, cards_to_check)
    cards_to_check.each do |card_id|
      pipefy_card_response = Pipefy::PipefyApiService.request_card_details(card_id)
      next if pipefy_card_response.code != 200
      card_response = JSON.parse(pipefy_card_response.body)
      known_demand = project.demands.find_by(demand_id: card_id)
      Pipefy::PipefyCardResponseReader.instance.create_card!(team, card_response) || known_demand
    end
  end
end
