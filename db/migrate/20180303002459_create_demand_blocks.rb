# frozen_string_literal: true

class CreateDemandBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :demand_blocks do |t|
      t.integer :demand_id, null: false, index: true
      t.integer :demand_block_id, null: false

      t.string :blocker_username, null: false
      t.datetime :block_time, null: false
      t.string :block_reason, null: false

      t.string :unblocker_username, null: true
      t.datetime :unblock_time, null: true
      t.string :unblock_reason, null: true

      t.integer :block_duration, null: true

      t.timestamps
    end

    add_foreign_key :demand_blocks, :demands, column: :demand_id, index: true
  end
end
