# frozen_string_literal: true

class AddAverageDemandCostToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :cost_in_week, :decimal, null: false
    add_column :project_results, :average_demand_cost, :decimal, null: false
  end
end
