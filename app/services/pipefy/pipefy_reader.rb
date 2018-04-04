# frozen_string_literal: true

module Pipefy
  class PipefyReader
    include Singleton

    def read_phase(phase_id)
      cards_in_pipe = []
      phase_response = Pipefy::PipefyApiService.request_cards_to_phase(phase_id)
      return [] if phase_response.code != 200
      cards_in_pipe.concat(read_phase_response(phase_id, phase_response))
      cards_in_pipe
    end

    def read_project_name_from_pipefy_data(response_data)
      project_pipefy_name = ''
      response_data.try(:[], 'card').try(:[], 'fields')&.each do |field|
        next unless field['name'].casecmp('project').zero?
        project_pipefy_name = field['value']
      end
      project_pipefy_name
    end

    private

    def read_phase_response(phase_id, phase_response)
      cards_in_pipe = []
      cards_in_phase = JSON.parse(phase_response.body)
      return [] if cards_in_phase['data']['phase'].blank?
      root_cards = cards_in_phase['data']['phase']['cards']
      cards_in_pipe.concat(root_cards['edges'].map { |edge| edge['node']['id'] })
      cards_in_pipe.concat(read_all_the_cards_in_phase(phase_id, root_cards)) if root_cards['pageInfo']['hasNextPage']
      cards_in_pipe
    end

    def read_all_the_cards_in_phase(phase_id, root_cards)
      card_in_pages = []
      root_cards_updated = root_cards
      while root_cards_updated['pageInfo']['hasNextPage']
        cards_in_phase = JSON.parse(Pipefy::PipefyApiService.request_next_page_cards_to_phase(phase_id, root_cards_updated['pageInfo']['endCursor']).body)
        root_cards_updated = cards_in_phase['data']['phase']['cards']
        card_in_pages.concat(root_cards_updated['edges'].map { |edge| edge['node']['id'] })
      end
      card_in_pages.flatten.uniq
    end
  end
end
