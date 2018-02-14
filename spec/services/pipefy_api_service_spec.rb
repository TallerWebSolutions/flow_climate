# frozen_string_literal: true

RSpec.describe PipefyApiService, type: :service do
  let(:base_uri) { 'https://app.pipefy.com/queries' }
  let(:headers) { { Authorization: "Bearer #{Figaro.env.pipefy_token}" } }

  describe '.request_card_details' do
    it 'calls HTTParty' do
      expect(HTTParty).to receive(:post).with(base_uri, body: { query: PipefyProtocol.card_show_request_body(222) }, headers: headers).once
      PipefyApiService.request_card_details('222')
    end
  end
  describe '.request_pipe_details_with_card_summary' do
    it 'calls HTTParty' do
      expect(HTTParty).to receive(:post).with(base_uri, body: { query: PipefyProtocol.pipe_show_request_body(222) }, headers: headers).once
      PipefyApiService.request_pipe_details_with_card_summary('222')
    end
  end
end
