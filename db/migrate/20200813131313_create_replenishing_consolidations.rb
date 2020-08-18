# frozen-string-literal: true

class CreateReplenishingConsolidations < ActiveRecord::Migration[6.0]
  def change
    create_table :replenishing_consolidations do |t|
      t.integer :project_id, null: false, index: true
      t.date :consolidation_date, null: false, index: true

      t.decimal :project_based_risks_to_deadline
      t.decimal :flow_pressure
      t.decimal :relative_flow_pressure
      t.decimal :qty_using_pressure
      t.decimal :leadtime_80
      t.decimal :qty_selected_last_week
      t.decimal :work_in_progress
      t.decimal :montecarlo_80_percent
      t.decimal :customer_happiness
      t.integer :max_work_in_progress
      t.integer :project_throughput_data, array: true
      t.integer :throughput_data_stddev
      t.decimal :team_based_montecarlo_80_percent
      t.decimal :team_monte_carlo_weeks_std_dev
      t.decimal :team_monte_carlo_weeks_min
      t.decimal :team_monte_carlo_weeks_max
      t.decimal :team_based_odds_to_deadline

      t.timestamps
    end
  end
end
