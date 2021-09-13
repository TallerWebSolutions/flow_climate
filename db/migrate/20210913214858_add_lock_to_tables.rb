# frozen_string_literal: true

class AddLockToTables < ActiveRecord::Migration[6.1]
  def change
    add_column :item_assignments, :lock_version, :integer
    add_column :demand_transitions, :lock_version, :integer
  end
end
