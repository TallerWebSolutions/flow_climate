# frozen_string_literal: true

class ChangeUniqueInDemandEffort < ActiveRecord::Migration[6.1]
  def change
    remove_index :demand_efforts, %i[item_assignment_id demand_transition_id]
    add_index :demand_efforts, %i[item_assignment_id demand_transition_id start_time_to_computation], unique: true, name: 'idx_demand_efforts_unique'
  end
end
