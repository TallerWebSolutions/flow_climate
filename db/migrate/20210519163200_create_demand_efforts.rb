# frozen_string_literal: true

class CreateDemandEfforts < ActiveRecord::Migration[6.1]
  def change
    create_table :demand_efforts do |t|
      t.integer :item_assignment_id, null: false, index: true
      t.integer :demand_transition_id, null: false, index: true
      t.integer :demand_id, null: false, index: true

      t.boolean :main_effort_in_transition, default: false, null: false
      t.boolean :automatic_update, default: true, null: false

      t.datetime :start_time_to_computation, null: false
      t.datetime :finish_time_to_computation, null: false
      t.decimal :effort_value, null: false, default: 0

      t.decimal :management_percentage, null: false, default: 0
      t.decimal :pairing_percentage, null: false, default: 0
      t.decimal :stage_percentage, null: false, default: 0

      t.decimal :total_blocked, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :demand_efforts, :item_assignments, column: :item_assignment_id
    add_foreign_key :demand_efforts, :demand_transitions, column: :demand_transition_id
    add_foreign_key :demand_efforts, :demands, column: :demand_id

    add_index :demand_efforts, %i[item_assignment_id demand_transition_id], unique: true, name: 'idx_demand_efforts_unique'
  end
end
