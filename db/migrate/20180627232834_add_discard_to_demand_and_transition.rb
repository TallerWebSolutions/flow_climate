# frozen_string_literal: true

class AddDiscardToDemandAndTransition < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :discarded_at, :datetime
    add_index :demands, :discarded_at

    add_column :demand_transitions, :discarded_at, :datetime
    add_index :demand_transitions, :discarded_at
  end
end
