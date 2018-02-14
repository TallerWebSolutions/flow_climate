# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    return if data.empty?

    card_response = JSON.parse(PipefyApiService.request_card_details(data.try(:[], 'data').try(:[], 'card').try(:[], 'id')).body)
    pipe_response = JSON.parse(PipefyApiService.request_pipe_details_with_card_summary(card_response.try(:[], 'data').try(:[], 'card').try(:[], 'pipe').try(:[], 'id')).body)
    process_card(PipefyData.new(card_response, pipe_response))
  end

  private

  def process_card(pipefy_data)
    pipefy_configs = PipefyConfig.where(pipe_id: pipefy_data.pipe_id)

    return if pipefy_configs.blank?

    project = pipefy_configs.first.project
    team = pipefy_configs.first.team
    update_card(project, team, pipefy_data)
  end

  def update_card(project, team, pipefy_data)
    demand = Demand.where(demand_id: pipefy_data.demand_id).first_or_initialize
    hours_consumed = DemandService.instance.compute_effort_for_dates(pipefy_data.commitment_date, pipefy_data.end_date)
    project_result = ProjectResultsRepository.instance.create_project_result(project, team, pipefy_data.end_date)
    DemandsRepository.instance.update_demand_and_project_result(demand, hours_consumed, pipefy_data.demand_type, pipefy_data.created_date, pipefy_data.commitment_date, pipefy_data.end_date, pipefy_data.known_scope, project, project_result)
  end
end
