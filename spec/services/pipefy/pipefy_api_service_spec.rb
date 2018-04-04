# frozen_string_literal: true

RSpec.describe Pipefy::PipefyApiService, type: :service do
  let(:base_uri) { 'https://app.pipefy.com/queries' }
  let(:headers) { { Authorization: "Bearer #{Figaro.env.pipefy_token}" } }

  describe '.request_card_details' do
    it 'calls HTTParty' do
      expect(HTTParty).to receive(:post).with(base_uri, body: { query: PipefyProtocol.card_show_request_body(222) }, headers: headers).once
      Pipefy::PipefyApiService.request_card_details('222')
    end
  end
  describe '.request_pipe_details' do
    it 'calls HTTParty' do
      expect(HTTParty).to receive(:post).with(base_uri, body: { query: PipefyProtocol.pipe_show_request_body(222) }, headers: headers).once
      Pipefy::PipefyApiService.request_pipe_details('222')
    end
  end
  describe '.request_cards_to_phase' do
    it 'calls HTTParty' do
      expect(HTTParty).to receive(:post).with(base_uri, body: { query: PipefyProtocol.phase_cards_request_pages(222) }, headers: headers).once
      Pipefy::PipefyApiService.request_cards_to_phase('222')
    end
  end
  describe '.request_next_page_cards_to_phase' do
    it 'calls HTTParty' do
      expect(HTTParty).to receive(:post).with(base_uri, body: { query: PipefyProtocol.phase_cards_paginated(222, 'aswqdf') }, headers: headers).once
      Pipefy::PipefyApiService.request_next_page_cards_to_phase('222', 'aswqdf')
    end
  end
end
