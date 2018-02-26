# frozen_string_literal: true

class ProcessPipefyCardJob < ApplicationJob
  def perform(data)
    return if data.empty?

    card_response = JSON.parse(PipefyApiService.request_card_details(data.try(:[], 'data').try(:[], 'card').try(:[], 'id')).body)
    PipefyReader.instance.process_response(card_response)
  end
end
