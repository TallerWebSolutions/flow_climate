# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    return if data.empty?

    card_response = JSON.parse(PipefyApiService.request_card_details(data.try(:[], 'data').try(:[], 'card').try(:[], 'id')).body)
    process_card(PipefyData.new(card_response))
  end

  private

  def process_card(pipefy_data)
    pipefy_configs = PipefyConfig.where(pipe_id: pipefy_data.pipe_id)

    return if pipefy_configs.blank?

    project = pipefy_configs.first.project
    team = pipefy_configs.first.team
    DemandsRepository.instance.create_or_update_demand(project, team, pipefy_data.demand_id, pipefy_data.demand_type, pipefy_data.commitment_date, pipefy_data.created_date, pipefy_data.end_date, pipefy_data.url)
  end
end
