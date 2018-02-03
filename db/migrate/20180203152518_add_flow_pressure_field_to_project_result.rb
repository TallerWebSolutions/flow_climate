# frozen_string_literal: true

class AddFlowPressureFieldToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :flow_pressure, :decimal, null: false
    add_column :project_results, :remaining_days, :integer, null: false
  end
end
