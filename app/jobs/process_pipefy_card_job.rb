# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    return if data.empty?
    demand_id = data.try(:[], 'data').try(:[], 'card').try(:[], 'id')
    card_response = JSON.parse(PipefyApiService.request_card_details(demand_id).body)
    pipefy_config = PipefyConfig.where(pipe_id: card_response['data']['card']['pipe']['id']).first
    return if pipefy_config.blank?

    process_card!(card_response, demand_id, pipefy_config)
  end

  private

  def process_card!(card_response, demand_id, pipefy_config)
    PipefyReader.instance.create_card!(pipefy_config.team, card_response)
    demand = Demand.find_by(demand_id: demand_id)
    PipefyReader.instance.update_card!(pipefy_config.team, demand, card_response) if demand.present?
  end
end
