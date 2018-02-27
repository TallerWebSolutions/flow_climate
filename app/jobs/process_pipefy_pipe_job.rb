# frozen_string_literal: true

class ProcessPipefyPipeJob < ApplicationJob
  def perform(full_reading)
    pipefy_configs = PipefyConfig.select('pipe_id, team_id').group(:pipe_id, :team_id)

    pipefy_configs.each do |config|
      pipe_response = JSON.parse(PipefyApiService.request_pipe_details_with_card_summary(config.pipe_id).body)
      cards_in_pipe = read_cards_from_pipe_response(pipe_response, full_reading)
      cards_in_pipe.each do |card_id|
        card_response = JSON.parse(PipefyApiService.request_card_details(card_id).body)
        PipefyReader.instance.process_card(config.team, card_response)
      end
      ProjectResultsRepository.instance.update_processed_project_results(cards_in_pipe)
    end
  end

  private

  def read_cards_from_pipe_response(pipe_response, full_read)
    cards_in_pipe = []
    pipe_response['data']['pipe']['phases'].each { |phase| read_phase(cards_in_pipe, full_read, phase) }
    cards_in_pipe.flatten.uniq
  end

  def read_phase(cards_in_pipe, full_read, phase)
    phase_id = phase['id']
    cards_in_phase = JSON.parse(PipefyApiService.request_cards_to_phase(phase_id).body)
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
