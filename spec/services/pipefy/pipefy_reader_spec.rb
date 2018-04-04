# frozen_string_literal: true

RSpec.describe Pipefy::PipefyReader, type: :service do
  let(:headers) { { Authorization: "Bearer #{Figaro.env.pipefy_token}" } }

  describe '#read_phase' do
    context 'having cards in the response' do
      let(:phase_response) { { data: { phase: { cards: { pageInfo: { endCursor: 'WzUxNDEwNDdd', hasNextPage: false }, edges: [{ node: { id: '4648391' } }, { node: { id: '4648389' } }] } } } }.with_indifferent_access }
      it 'reads the card in the phase' do
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /1234/).to_return(status: 200, body: phase_response.to_json, headers: {})
        cards = Pipefy::PipefyReader.instance.read_phase('1234')
        expect(cards).to eq %w[4648391 4648389]
      end
    end
    context 'having no cards in the response' do
      let(:phase_response) { { data: { phase: { cards: { pageInfo: { endCursor: 'WzUxNDEwNDdd', hasNextPage: false }, edges: [] } } } }.with_indifferent_access }
      it 'reads the card in the phase' do
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /1234/).to_return(status: 200, body: phase_response.to_json, headers: {})
        cards = Pipefy::PipefyReader.instance.read_phase('1234')
        expect(cards).to eq []
      end
    end
    context 'when the response is null to phase' do
      let(:phase_response) { { data: { phase: nil } }.with_indifferent_access }
      it 'reads the card in the phase' do
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /1234/).to_return(status: 200, body: phase_response.to_json, headers: {})
        cards = Pipefy::PipefyReader.instance.read_phase('1234')
        expect(cards).to eq []
      end
    end
    context 'having more than one page' do
      let(:phase_with_pages_response) { { data: { phase: { cards: { pageInfo: { endCursor: 'WzUxNDEwNDdd', hasNextPage: true }, edges: [{ node: { id: '4648391' } }] } } } }.with_indifferent_access }
      let(:phase_without_pages_response) { { data: { phase: { cards: { pageInfo: { endCursor: '388jjssjxgt2', hasNextPage: false }, edges: [{ node: { id: '4648389' } }] } } } }.with_indifferent_access }
      let(:with_page_response) { double('Response', code: 200, body: phase_with_pages_response.to_json) }
      let(:without_pages_response) { double('Response', code: 200, body: phase_without_pages_response.to_json) }
      before do
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481594/).to_return(status: 200, body: phase_with_pages_response.to_json, headers: {})
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481595/).to_return(status: 200, body: phase_without_pages_response.to_json, headers: {})
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481596/).to_return(status: 200, body: phase_without_pages_response.to_json, headers: {})
        stub_request(:post, 'https://app.pipefy.com/queries').with(headers: headers, body: /2481597/).to_return(status: 200, body: phase_without_pages_response.to_json, headers: {})
      end

      it 'paginates the call' do
        expect(Pipefy::PipefyApiService).to receive(:request_next_page_cards_to_phase) { without_pages_response }
        cards = Pipefy::PipefyReader.instance.read_phase('2481594')
        expect(cards).to eq %w[4648391 4648389]
      end
    end
  end

  pending '#read_project_name_from_pipefy_data'
end
