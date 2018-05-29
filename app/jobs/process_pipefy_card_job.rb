# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(card_data)
    return if card_data.empty?
    pipefy_response = Pipefy::PipefyApiService.request_card_details(card_data.try(:[], 'data').try(:[], 'card').try(:[], 'id'))
    return unless pipefy_response.code == 200
    card_response = JSON.parse(pipefy_response.body)
    pipefy_config = Pipefy::PipefyConfig.where(pipe_id: card_response['data']['card']['pipe']['id']).first
    return if pipefy_config.blank?

    process_card!(pipefy_config.team, card_response)
  end

  private

  def process_card!(team, card_response)
    project_full_name = Pipefy::PipefyReader.instance.read_project_name_from_pipefy_data(card_response['data'])
    return if project_full_name.blank?
    project = ProjectsRepository.instance.search_project_by_full_name(project_full_name)
    return if project.blank?
    demand = Pipefy::PipefyCardResponseReader.instance.create_card!(project, team, card_response)
    return if demand.blank?
    Pipefy::PipefyCardResponseReader.instance.update_card!(project, team, demand, card_response)
    demand.project.project_results.map(&:compute_flow_metrics!)
  end
end
