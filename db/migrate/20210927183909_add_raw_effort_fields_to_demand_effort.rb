# frozen_string_literal: true

class AddRawEffortFieldsToDemandEffort < ActiveRecord::Migration[6.1]
  def change
    change_table :demand_efforts do |t|
      t.decimal :effort_with_blocks, default: 0
    end
  end
end
