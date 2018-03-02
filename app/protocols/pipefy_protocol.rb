# frozen_string_literal: true

class PipefyProtocol
  def self.card_show_request_body(card_id)
    "{card(id: #{card_id}) { id assignees { id } comments { text } fields { name value } phases_history { phase { id } firstTimeIn lastTimeOut } pipe { id } url } }"
  end

  def self.pipe_show_request_body(pipe_id)
    "{ pipe(id: #{pipe_id}) { phases { id } } }"
  end

  def self.phase_cards_request_pages(phase_id)
    "{ phase(id: #{phase_id}) { cards(first: 30) { pageInfo { endCursor hasNextPage } edges { node { id } } } } }"
  end

  def self.phase_cards_paginated(phase_id, after)
    "{ phase(id: #{phase_id}) { cards(first: 30, after: \"#{after}\") { pageInfo { endCursor hasNextPage } edges { node { id } } } } }"
  end
end
