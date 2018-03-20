# frozen_string_literal: true

class AddColumnActiveToDemandBlocks < ActiveRecord::Migration[5.1]
  def change
    add_column :demand_blocks, :active, :boolean, default: true, null: false
  end
end
