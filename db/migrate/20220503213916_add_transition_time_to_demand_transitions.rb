# frozen_string_literal: true

class AddTransitionTimeToDemandTransitions < ActiveRecord::Migration[7.0]
  def change
    add_column :demand_transitions, :transition_time_in_sec, :integer, default: 0
  end
end
