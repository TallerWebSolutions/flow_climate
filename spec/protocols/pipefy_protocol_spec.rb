# frozen_string_literal: true

RSpec.describe PipefyProtocol, type: :protocol do
  describe '.card_show_request_body' do
    it { expect(PipefyProtocol.card_show_request_body('222')).to eq '{card(id: 222) { id comments { text } fields { name value } phases_history { phase { id } firstTimeIn lastTimeOut } pipe { id } url } }' }
  end
  describe '.pipe_show_request_body' do
    it { expect(PipefyProtocol.pipe_show_request_body('222')).to eq '{ pipe(id: 222) { phases { id } } }' }
  end
  describe '.phase_cards_request_pages' do
    it { expect(PipefyProtocol.phase_cards_request_pages('222')).to eq '{ phase(id: 222) { cards(first: 30) { pageInfo { endCursor hasNextPage } edges { node { id } } } } }' }
  end
  describe '.phase_cards_paginated' do
    it { expect(PipefyProtocol.phase_cards_paginated('222', '245')).to eq '{ phase(id: 222) { cards(first: 30, after: "245") { pageInfo { endCursor hasNextPage } edges { node { id } } } } }' }
  end
end
