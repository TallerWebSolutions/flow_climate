# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    base_uri = 'https://app.pipefy.com'
    token = Figaro.env.pipefy_token
    headers = {
      Authorization: "Bearer #{token}"
    }

    return if data.empty?

    card_response = JSON.parse(card_details(base_uri, data, headers).body)
    pipe_id = card_response.try(:[], 'data').try(:[], 'card').try(:[], 'pipe').try(:[], 'id')
    pipe_response = JSON.parse(pipe_details(base_uri, headers, pipe_id).body)
    pipefy_data = PipefyData.new(card_response, pipe_response)
    process_card(pipefy_data)
  end

  private

  def card_details(base_uri, data, headers)
    HTTParty.post(
      "#{base_uri}/queries",
      body: { query: card_show_request_body(data.try(:[], 'data').try(:[], 'card').try(:[], 'id')) },
      headers: headers
    )
  end

  def pipe_details(base_uri, headers, pipe_id)
    HTTParty.post(
      "#{base_uri}/queries",
      body: { query: pipe_show_request_body(pipe_id) },
      headers: headers
    )
  end

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

  def card_show_request_body(card_id)
    "{card(id: #{card_id}) { id title assignees { id } comments { text } comments_count current_phase { name } done due_date fields { name value } labels { name } phases_history { phase { id name done fields { label } } firstTimeIn lastTimeOut } pipe { id } url } }"
  end

  def pipe_show_request_body(pipe_id)
    "{ pipe(id: #{pipe_id}) { phases { cards { edges { node { id title } } } } } }"
  end
end
