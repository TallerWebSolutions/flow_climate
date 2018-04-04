# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    return if data.empty?
    demand_id = data.try(:[], 'data').try(:[], 'card').try(:[], 'id')
    card_response = JSON.parse(PipefyApiService.request_card_details(demand_id).body)
    pipefy_config = PipefyConfig.where(pipe_id: card_response['data']['card']['pipe']['id']).first
    return if pipefy_config.blank?

    process_card!(pipefy_config.team, card_response)
  end

  private

  def process_card!(team, card_response)
    project_full_name = PipefyReader.instance.read_project_name_from_pipefy_data(card_response['data'])
    return if project_full_name.blank?
    project = ProjectsRepository.instance.search_project_by_full_name(project_full_name)
    return if project.blank?
    demand = PipefyResponseReader.instance.create_card!(project, team, card_response)
    return if demand.blank?
    PipefyResponseReader.instance.update_card!(project, team, demand, card_response)
    demand.project.project_results.map(&:compute_flow_metrics!)
  end
end
