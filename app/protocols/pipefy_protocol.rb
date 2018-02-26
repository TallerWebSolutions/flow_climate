# frozen_string_literal: true

class PipefyProtocol
  def self.card_show_request_body(card_id)
    "{card(id: #{card_id}) { id title assignees { id } comments { text } comments_count current_phase { name } done due_date fields { name value } labels { name } phases_history { phase { id name done fields { label } } lastTimeIn lastTimeOut } pipe { id } url } }"
  end

  def self.pipe_show_request_body(pipe_id)
    "{ pipe(id: #{pipe_id}) { phases { cards { edges { node { id title } } } } } }"
  end
end
