# frozen_string_literal: true

RSpec.describe PipefyProtocol, type: :protocol do
  describe '.card_show_request_body' do
    it { expect(PipefyProtocol.card_show_request_body('222')).to eq '{card(id: 222) { id title assignees { id } comments { text } comments_count current_phase { name } done due_date fields { name value } labels { name } phases_history { phase { id name done fields { label } } firstTimeIn lastTimeOut } pipe { id } url } }' }
  end
  describe '.pipe_show_request_body' do
    it { expect(PipefyProtocol.pipe_show_request_body('222')).to eq '{ pipe(id: 222) { phases { cards { edges { node { id title } } } } } }' }
  end
end
