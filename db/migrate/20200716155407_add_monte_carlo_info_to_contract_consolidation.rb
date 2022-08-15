# frozen_string_literal: true

class AddMonteCarloInfoToContractConsolidation < ActiveRecord::Migration[6.0]
  def change
    change_table :contract_consolidations, bulk: true do |t|
      t.integer :min_monte_carlo_weeks, default: 0
      t.integer :max_monte_carlo_weeks, default: 0
      t.integer :monte_carlo_duration_p80_weeks, default: 0

      t.integer :estimated_hours_per_demand
      t.integer :real_hours_per_demand
    end
  end
end
