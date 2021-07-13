# frozen_string_literal: true

class AddDiscardToDemandsChildren < ActiveRecord::Migration[6.0]
  def change
    add_column :demand_comments, :discarded_at, :datetime
    add_index :demand_comments, :discarded_at
    add_column :item_assignments, :discarded_at, :datetime
    add_index :item_assignments, :discarded_at
    add_column :flow_impacts, :discarded_at, :datetime
    add_index :flow_impacts, :discarded_at
  end
end
