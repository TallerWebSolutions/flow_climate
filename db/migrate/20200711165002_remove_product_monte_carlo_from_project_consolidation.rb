# frozen_string_literal: true

class RemoveProductMonteCarloFromProjectConsolidation < ActiveRecord::Migration[6.0]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.remove :products_monte_carlo_weeks
      t.remove :products_weekly_throughput
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.integer :products_monte_carlo_weeks, array: true
      t.integer :products_weekly_throughput, array: true
    end
  end
end
