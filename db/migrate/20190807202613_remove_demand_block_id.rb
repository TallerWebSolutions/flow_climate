# frozen_string_literal: true

class RemoveDemandBlockId < ActiveRecord::Migration[5.2]
  def change
    remove_column :demand_blocks, :demand_block_id, :integer
  end
end
