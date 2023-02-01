# frozen_string_literal: true

class RemoveEffortBlockedFromDemandEfforts < ActiveRecord::Migration[7.0]
  def change
    remove_column :demand_efforts, :effort_with_blocks, :float
  end
end
