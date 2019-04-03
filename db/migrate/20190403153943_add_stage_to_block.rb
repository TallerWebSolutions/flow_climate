# frozen_string_literal: true

class AddStageToBlock < ActiveRecord::Migration[5.2]
  def change
    change_table :demand_blocks, bulk: true do |t|
      t.integer :stage_id, index: true
    end

    add_foreign_key :demand_blocks, :stages, column: :stage_id
  end
end
