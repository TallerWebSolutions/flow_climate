# frozen_string_literal: true

class AddFlowPressureFieldToProjectResult < ActiveRecord::Migration[5.1]
  def change
    change_table :project_results, bulk: true do |t|
      t.decimal :flow_pressure, null: false
      t.integer :remaining_days, null: false
    end
  end
end
