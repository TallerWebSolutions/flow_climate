# frozen_string_literal: true

class WebhookIntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def pipefy_webhook
    return head :bad_request if request.headers['Content-Type'] != 'application/json'
    data = JSON.parse(request.body.read)
    process_card_moved_to_done(data)
    head :ok
  end

  private

  def process_card_moved_to_done(data)
    base_uri = 'https://app.pipefy.com'
    token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlkIjoxMDEzODEsImVtYWlsIjoiY2Vsc29AdGFsbGVyLm5ldC5iciIsImFwcGxpY2F0aW9uIjo0NzA4fX0.0gKv0iZ5D5wu2fnKKxTvINBkJvohusrB2LxyvMeLsDyn13eAI5sPwcyhneYfgTQp2V_e96G_oy_wxYzBezdLOg'
    headers = {
      Authorization: "Bearer #{token}"
    }

    return if data.empty?

    card_response = JSON.parse(card_details(base_uri, data, headers))
    pipe_id = card_response.try(:[], 'data').try(:[], 'card').try(:[], 'pipe').try(:[], 'id')
    pipe_response = JSON.parse(pipe_details(base_uri, headers, pipe_id))
    pipefy_data = PipefyData.new(card_response, pipe_response)
    process_card(pipefy_data)
  end

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
    demand.demand_type = pipefy_data.demand_type
    hours_consumed = calculate_hours_consumed(pipefy_data.commitment_date, pipefy_data.end_date)
    project_result = create_project_result(pipefy_data.end_date, project, team)
    demand.update(project_result: project_result, end_date: pipefy_data.end_date, commitment_date: pipefy_data.commitment_date, effort: hours_consumed)
    ProjectResultsRepository.instance.update_result_for_date(project, demand.end_date, pipefy_data.known_scope, 0)
  end

  def create_project_result(end_date, project, team)
    project_results = ProjectResult.where(result_date: end_date, project: project)
    return create_new_project_result(end_date, project, team) if project_results.blank?
    project_results.first
  end

  def create_new_project_result(end_date, project, team)
    ProjectResult.create(project: project, result_date: end_date, known_scope: 0, throughput: 0, qty_hours_upstream: 0,
                         qty_hours_downstream: 0, qty_hours_bug: 0, qty_bugs_closed: 0, qty_bugs_opened: 0,
                         team: team, flow_pressure: 0, remaining_days: project.remaining_days, cost_in_week: (team.outsourcing_cost / 4),
                         average_demand_cost: 0, available_hours: team.current_outsourcing_monthly_available_hours)
  end

  def calculate_hours_consumed(commitment_date, end_date)
    return (end_date - commitment_date) / 1.hour if commitment_date.to_date == end_date.to_date
    start_date = commitment_date
    business_days = 0
    while start_date <= end_date
      business_days += 1 unless start_date.saturday? || start_date.sunday?
      start_date += 1.day
    end
    business_days * 8
  end

  def card_show_request_body(card_id)
    "{card(id: #{card_id}) { id title assignees { id } comments { text } comments_count current_phase { name } done due_date fields { name value } labels { name } phases_history { phase { id name done fields { label } } firstTimeIn lastTimeOut } pipe { id } url } }"
  end

  def pipe_show_request_body(pipe_id)
    "{ pipe(id: #{pipe_id}) { phases { cards { edges { node { id title } } } } } }"
  end
end
