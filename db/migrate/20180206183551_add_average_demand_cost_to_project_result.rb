# frozen_string_literal: true

class AddAverageDemandCostToProjectResult < ActiveRecord::Migration[5.1]
  def change
    change_table :project_results, bulk: true do |t|
      t.decimal :cost_in_week, null: false
      t.decimal :average_demand_cost, null: false
    end
  end
end
