# frozen_string_literal: true

class AddUniqueConstraintToItemAssignment < ActiveRecord::Migration[8.0]
  def change
    add_index :item_assignments, %i[demand_id membership_id start_time], unique: true

    add_index :demand_efforts, %i[item_assignment_id demand_transition_id start_time_to_computation], unique: true
  end
end
