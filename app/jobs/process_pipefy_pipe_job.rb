# frozen_string_literal: true

class ProcessPipefyPipeJob < ApplicationJob
  def perform
    pipefy_configs = PipefyConfig.all

    pipefy_configs.each do |config|
      pipe_response = JSON.parse(PipefyApiService.request_pipe_details_with_card_summary(config.pipe_id).body)
      cards_in_pipe = read_cards_from_pipe_response(pipe_response)
      cards_in_pipe.each do |card_id|
        card_response = JSON.parse(PipefyApiService.request_card_details(card_id).body)
        PipefyReader.instance.process_response(card_response)
      end
    end
  end

  private

  def read_cards_from_pipe_response(pipe_response)
    cards_in_pipe = []
    pipe_response['data']['pipe']['phases'].each do |phase|
      phase['cards'].each { |cards| cards[1].each { |card| cards_in_pipe << card['node']['id'] } }
    end
    cards_in_pipe
  end
end
