# frozen_string_literal: true

class Make < ActiveRecord::Migration[8.0]
  def change
    change_column_null :operations_dashboard_pairings, :pair_id, true
    change_column_null :demand_blocks, :blocker_id, true
  end
end
