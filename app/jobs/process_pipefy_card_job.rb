# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    return if data.empty?
    card_response = JSON.parse(PipefyApiService.request_card_details(data.try(:[], 'data').try(:[], 'card').try(:[], 'id')).body)
    pipefy_config = PipefyConfig.where(pipe_id: card_response['data']['card']['pipe']['id']).first
    return if pipefy_config.blank?
    PipefyReader.instance.process_card(pipefy_config.team, card_response)
  end
end
