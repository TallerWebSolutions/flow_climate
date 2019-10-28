# frozen_string_literal: true

class AddBlockedWorkingTimeToDemandBlocks < ActiveRecord::Migration[6.0]
  def up
    change_table :demand_blocks, bulk: true do |t|
      t.decimal :block_working_time_duration
      t.remove :block_duration
    end

    DemandBlock.all.map(&:save)
  end

  def down
    change_table :demand_blocks, bulk: true do |t|
      t.remove :block_working_time_duration
      t.decimal :block_duration
    end
  end
end
