# frozen_string_literal: true

class PipefyApiService
  BASE_URI = 'https://app.pipefy.com'
  HEADERS = { Authorization: "Bearer #{Figaro.env.pipefy_token}" }.freeze

  def self.request_card_details(card_id)
    HTTParty.post(
      "#{BASE_URI}/queries",
      body: { query: PipefyProtocol.card_show_request_body(card_id) },
      headers: HEADERS
    )
  end

  def self.request_pipe_details_with_card_summary(pipe_id)
    HTTParty.post(
      "#{BASE_URI}/queries",
      body: { query: PipefyProtocol.pipe_show_request_body(pipe_id) },
      headers: HEADERS
    )
  end

  def self.request_cards_to_phase(phase_id)
    HTTParty.post(
      "#{BASE_URI}/queries",
      body: { query: PipefyProtocol.phase_cards_request_pages(phase_id) },
      headers: HEADERS
    )
  end

  def self.request_next_page_cards_to_phase(phase_id, cursor)
    HTTParty.post(
      "#{BASE_URI}/queries",
      body: { query: PipefyProtocol.phase_cards_paginated(phase_id, cursor) },
      headers: HEADERS
    )
  end
end
