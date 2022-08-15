# frozen_string_literal: true

class CreateDemandBlockNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :demand_block_notifications do |t|
      t.integer :demand_block_id, index: true, null: false
      t.integer :block_state, index: true, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :demand_block_notifications, :demand_blocks, column: :demand_block_id
  end
end
