# frozen_string_literal: true

class RemoveReasonFromDemandBlock < ActiveRecord::Migration[5.2]
  def up
    change_table :demand_blocks, bulk: true do |t|
      t.remove :block_reason
      t.remove :unblock_reason
    end
  end

  def down
    change_table :demand_blocks, bulk: true do |t|
      t.string :block_reason
      t.string :unblock_reason
    end
  end
end
