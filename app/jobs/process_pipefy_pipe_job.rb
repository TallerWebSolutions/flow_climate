# frozen_string_literal: true

class ProcessPipefyPipeJob < ApplicationJob
  def perform
    cards_response_hash = read_pipe_and_create_cards!

    processed_projects = read_demands_in_pipefy!(cards_response_hash)
    processed_projects.uniq.each { |updated_project| updated_project.project_results.order(:result_date).joins(demands: :demand_transitions).map(&:compute_flow_metrics!) if updated_project.present? }
  end

  private

  def read_pipe_and_create_cards!
    cards_response_hash = {}
    PipefyConfig.select(:pipe_id).where(active: true).group(:pipe_id).map(&:pipe_id).each do |pipe_id|
      pipe_response = PipefyApiService.request_pipe_details(pipe_id)
      next if pipe_response.code != 200
      team = PipefyConfig.find_by(pipe_id: pipe_id).team
      cards_response_hash.merge!(process_succeeded_pipe_response(team, pipe_response))
    end
    cards_response_hash
  end

  def read_demands_in_pipefy!(cards_response_hash)
    processed_projects = []
    Demand.demands_with_integration.each do |demand|
      PipefyReader.instance.update_card!(demand.project.pipefy_config.team, demand, cards_response_hash[demand.demand_id])
      project = demand.project
      processed_projects << project unless processed_projects.include?(project)
    end
    processed_projects
  end

  def process_succeeded_pipe_response(team, pipe_response)
    cards_in_pipe = read_cards_inside_phases(JSON.parse(pipe_response.body))

    cards_response_hash = {}
    cards_in_pipe.sort.reverse.each do |card_id|
      card_response = PipefyApiService.request_card_details(card_id)
      next if card_response.code != 200
      parsed_card_response = JSON.parse(card_response.body)
      cards_response_hash[card_id] = parsed_card_response

      next if Demand.find_by(demand_id: card_id).present?
      PipefyReader.instance.create_card!(team, parsed_card_response)
    end
    cards_response_hash
  end

  def read_cards_inside_phases(pipe_response)
    cards_in_pipe = []
    pipe_response['data']['pipe']['phases'].each { |phase| cards_in_pipe.concat(read_phase(phase)) }
    cards_in_pipe.flatten.uniq
  end

  def read_phase(phase)
    cards_in_pipe = []
    phase_id = phase['id']
    phase_response = PipefyApiService.request_cards_to_phase(phase_id)
    return [] if phase_response.code != 200
    cards_in_pipe.concat(read_phase_response(phase_id, phase_response))
    cards_in_pipe
  end

  def read_phase_response(phase_id, phase_response)
    cards_in_pipe = []
    cards_in_phase = JSON.parse(phase_response.body)
    root_cards = cards_in_phase['data']['phase']['cards']
    cards_in_pipe.concat(root_cards['edges'].map { |edge| edge['node']['id'] })
    cards_in_pipe.concat(read_all_the_cards_in_phase(phase_id, root_cards)) if root_cards['pageInfo']['hasNextPage']
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
