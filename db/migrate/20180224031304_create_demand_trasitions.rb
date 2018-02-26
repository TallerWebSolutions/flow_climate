# frozen_string_literal: true

class CreateDemandTrasitions < ActiveRecord::Migration[5.1]
  def change
    create_table :demand_transitions do |t|
      t.integer :demand_id, null: false, index: true
      t.integer :stage_id, null: false, index: true
      t.datetime :last_time_in, null: false
      t.datetime :last_time_out

      t.timestamps
    end

    add_foreign_key :demand_transitions, :stages, column: :stage_id, index: true
    add_foreign_key :demand_transitions, :demands, column: :demand_id, index: true
  end
end
