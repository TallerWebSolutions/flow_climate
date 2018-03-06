# frozen_string_literal: true

class ProcessPipefyPipeJob < ApplicationJob
  def perform(full_reading)
    pipefy_configs = PipefyConfig.select('pipe_id, team_id').where(active: true).group(:pipe_id, :team_id)
    processed_projects = process_pipe(full_reading, pipefy_configs)
    processed_projects.uniq.each { |updated_project| updated_project.project_results.order(:result_date).joins(demands: :demand_transitions).map(&:compute_flow_metrics!) if updated_project.present? }
  end

  private

  def process_pipe(full_reading, pipefy_configs)
    processed_projects = []
    pipefy_configs.map { |pc| [pc] }.flatten.each do |config|
      pipe_response = PipefyApiService.request_pipe_details_with_card_summary(config.pipe_id)
      next if pipe_response.code != 200
      processed_projects.concat(process_success_pipe_response(config, full_reading, pipe_response))
    end
    processed_projects
  end

  def process_success_pipe_response(config, full_reading, pipe_response)
    cards_in_pipe = read_cards_from_pipe_response(JSON.parse(pipe_response.body), full_reading)

    processed_projects = []
    cards_in_pipe.sort.reverse.each do |card_id|
      card_response = PipefyApiService.request_card_details(card_id)
      next if card_response.code != 200
      processed_project = PipefyReader.instance.process_card(config.team, JSON.parse(card_response.body))
      processed_projects << processed_project unless processed_projects.include?(processed_project)
    end
    processed_projects
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
