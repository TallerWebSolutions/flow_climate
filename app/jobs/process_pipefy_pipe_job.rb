# frozen_string_literal: true

class ProcessPipefyPipeJob < ApplicationJob
  def perform(full_reading)
    process_pipe_and_create_cards!(full_reading)

    processed_projects = read_demands_in_pipefy!
    processed_projects.uniq.each { |updated_project| updated_project.project_results.order(:result_date).joins(demands: :demand_transitions).map(&:compute_flow_metrics!) if updated_project.present? }
  end

  private

  def read_demands_in_pipefy!
    processed_projects = []
    Demand.joins(project: :pipefy_config).joins(:demand_transitions).where('demands.demand_id IS NOT NULL AND pipefy_configs.active = true').uniq.each do |demand|
      project = demand.project
      pipefy_response = PipefyApiService.request_card_details(demand.demand_id)
      next if pipefy_response.code != 200
      card_response = JSON.parse(pipefy_response.body)
      process_card_response(demand, card_response)
      processed_projects << project unless processed_projects.include?(project)
    end
    processed_projects
  end

  def process_card_response(demand, card_response)
    deleted_demands = []
    if card_response['data']['card'].blank?
      project_result = demand.project_result
      project_result.remove_demand!(demand) if project_result.present?
      deleted_demands << demand.demand_id
      demand.destroy
    else
      PipefyReader.instance.update_card!(demand.project.pipefy_config.team, demand, card_response)
    end

    deleted_demands
  end

  def process_pipe_and_create_cards!(full_reading)
    PipefyConfig.select(:pipe_id).where(active: true).group(:pipe_id).map(&:pipe_id).each do |pipe_id|
      pipe_response = PipefyApiService.request_pipe_details_with_card_summary(pipe_id)
      next if pipe_response.code != 200
      team = PipefyConfig.find_by(pipe_id: pipe_id).team
      process_succeeded_pipe_response(team, full_reading, pipe_response)
    end
  end

  def process_succeeded_pipe_response(team, full_reading, pipe_response)
    cards_in_pipe = read_cards_from_pipe_response(JSON.parse(pipe_response.body), full_reading)

    cards_in_pipe.sort.reverse.each do |card_id|
      next if Demand.find_by(demand_id: card_id).present?
      card_response = PipefyApiService.request_card_details(card_id)
      next if card_response.code != 200
      PipefyReader.instance.create_card!(team, JSON.parse(card_response.body))
    end
  end

  def read_cards_from_pipe_response(pipe_response, full_read)
    cards_in_pipe = []
    pipe_response['data']['pipe']['phases'].each { |phase| read_phase(cards_in_pipe, full_read, phase) }
    cards_in_pipe.flatten.uniq
  end

  def read_phase(cards_in_pipe, full_read, phase)
    phase_id = phase['id']
    phase_response = PipefyApiService.request_cards_to_phase(phase_id)
    return if phase_response.code != 200
    process_success_phase_response(cards_in_pipe, full_read, phase_id, phase_response)
  end

  def process_success_phase_response(cards_in_pipe, full_read, phase_id, phase_response)
    cards_in_phase = JSON.parse(phase_response.body)
    root_cards = cards_in_phase['data']['phase']['cards']
    cards_in_pipe.concat(root_cards['edges'].map { |edge| edge['node']['id'] })
    cards_in_pipe.concat(read_all_the_cards_in_phase(phase_id, root_cards)) if full_read && root_cards['pageInfo']['hasNextPage']
    cards_in_pipe
  end

  def read_all_the_cards_in_phase(phase_id, root_cards)
    card_in_pages = []
    root_cards_updated = root_cards
    while root_cards_updated['pageInfo']['hasNextPage']
      cards_in_phase = JSON.parse(PipefyApiService.request_next_page_cards_to_phase(phase_id, root_cards_updated['pageInfo']['endCursor']).body)
      root_cards_updated = cards_in_phase['data']['phase']['cards']
      card_in_pages.concat(root_cards_updated['edges'].map { |edge| edge['node']['id'] })
    end
    card_in_pages.flatten.uniq
  end
end
