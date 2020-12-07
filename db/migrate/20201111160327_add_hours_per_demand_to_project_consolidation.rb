# frozen_string_literal: true

class AddHoursPerDemandToProjectConsolidation < ActiveRecord::Migration[6.0]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.decimal :hours_per_demand, default: 0
      t.decimal :flow_efficiency, default: 0
      t.integer :bugs_opened, default: 0
      t.integer :bugs_closed, default: 0

      t.decimal :lead_time_p65, default: 0
      t.decimal :lead_time_p95, default: 0

      t.decimal :lead_time_min_month, default: 0
      t.decimal :lead_time_max_month, default: 0
      t.decimal :lead_time_p80_month, default: 0
      t.decimal :lead_time_std_dev_month, default: 0

      t.decimal :flow_efficiency_month, default: 0
      t.decimal :hours_per_demand_month, default: 0

      t.integer :code_needed_blocks_count, default: 0
      t.decimal :code_needed_blocks_per_demand, default: 0

      t.change :monte_carlo_weeks_std_dev, :decimal
      t.change :team_based_monte_carlo_weeks_std_dev, :decimal
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.remove :hours_per_demand
      t.remove :flow_efficiency
      t.remove :bugs_opened
      t.remove :bugs_closed

      t.remove :lead_time_p65
      t.remove :lead_time_p95

      t.remove :lead_time_min_month
      t.remove :lead_time_max_month
      t.remove :lead_time_p80_month
      t.remove :lead_time_std_dev_month

      t.remove :flow_efficiency_month
      t.remove :hours_per_demand_month

      t.remove :code_needed_blocks_count
      t.remove :code_needed_blocks_per_demand

      t.change :monte_carlo_weeks_std_dev, :integer
      t.change :team_based_monte_carlo_weeks_std_dev, :integer
    end
  end
end
