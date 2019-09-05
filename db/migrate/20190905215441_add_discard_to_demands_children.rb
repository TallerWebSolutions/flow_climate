# frozen_string_literal: true

class AddDiscardToDemandsChildren < ActiveRecord::Migration[6.0]
  def change
    add_column :demand_comments, :discarded_at, :datetime, index: true
    add_column :item_assignments, :discarded_at, :datetime, index: true
    add_column :flow_impacts, :discarded_at, :datetime, index: true
  end
end
