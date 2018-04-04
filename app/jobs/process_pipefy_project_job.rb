# frozen_string_literal: true

class ProcessPipefyProjectJob < ApplicationJob
  def perform(project_id)
    project = Project.find_by(id: project_id)
    return if project.pipefy_config.blank?
    project.stages.each do |stage|
      cards_in_stage = Pipefy::PipefyReader.instance.read_phase(stage.integration_id)
      process_and_save_cards_in_phase!(project, project.pipefy_config.team, cards_in_stage)
    end
  end

  private

  def process_and_save_cards_in_phase!(project, team, cards_in_stage)
    cards_in_stage.each do |card_id|
      pipefy_response = Pipefy::PipefyApiService.request_card_details(card_id)
      next if pipefy_response.code != 200
      card_response = JSON.parse(pipefy_response.body)
      name_in_pipefy = Pipefy::PipefyReader.instance.read_project_name_from_pipefy_data(card_response['data'])
      next if name_in_pipefy.blank? || project.full_name != name_in_pipefy
      demand = Pipefy::PipefyResponseReader.instance.create_card!(project, team, card_response)
      Pipefy::PipefyResponseReader.instance.update_card!(project, team, demand, card_response)
    end
  end
end
