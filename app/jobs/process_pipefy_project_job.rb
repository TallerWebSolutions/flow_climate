# frozen_string_literal: true

class ProcessPipefyProjectJob < ApplicationJob
  def perform(project_id)
    project = Project.find_by(id: project_id)
    project.demands.each do |demand|
      pipefy_response = PipefyApiService.request_card_details(demand.demand_id)
      next if pipefy_response.code != 200
      card_response = JSON.parse(pipefy_response.body)
      PipefyReader.instance.update_card!(project.pipefy_config.team, demand, card_response)
    end
  end
end
