# frozen_string_literal: true

class AddPullIntervalToItemAssignment < ActiveRecord::Migration[6.0]
  def change
    add_column :item_assignments, :pull_interval, :decimal, default: 0
  end
end
