# frozen_string_literal: true

class AddBlockTypeToDemandBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_blocks, :block_type, :integer, default: 0, null: false
  end
end
