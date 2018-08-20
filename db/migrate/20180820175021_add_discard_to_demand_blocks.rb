# frozen_string_literal: true

class AddDiscardToDemandBlocks < ActiveRecord::Migration[5.2]
  def up
    add_column :demand_blocks, :discarded_at, :datetime, index: true

    Demand.discarded.each { |demand| demand.demand_blocks.each { |block| block.update(discarded_at: demand.discarded_at) } }
  end

  def down
    remove_column :demand_blocks, :discarded_at
  end
end
