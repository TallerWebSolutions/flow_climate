# frozen_string_literal: true

class CreateProjectConsolidations < ActiveRecord::Migration[5.2]
  def change
    create_table :project_consolidations do |t|
      t.date :consolidation_date, null: false

      t.integer :project_aging, null: false
      t.integer :weeks_to_deadline, null: false

      t.date :population_start_date, null: false
      t.date :population_end_date, null: false

      t.integer :project_id, null: false
      t.integer :demands_ids, array: true, null: false
      t.integer :demands_finished_ids, array: true, null: false

      t.decimal :demands_lead_times, array: true, null: false
      t.decimal :demands_lead_times_average, null: false
      t.decimal :demands_lead_times_std_dev, null: false

      t.decimal :lead_time_min, null: false
      t.decimal :lead_time_max, null: false
      t.decimal :total_range, null: false

      t.decimal :lead_time_histogram_bin_min, null: false
      t.decimal :lead_time_histogram_bin_max, null: false
      t.decimal :histogram_range, null: false

      t.decimal :lead_time_p25, null: false
      t.decimal :lead_time_p75, null: false
      t.decimal :interquartile_range, null: false

      t.integer :last_throughput_per_week_data, null: false, array: true
      t.decimal :last_lead_time_p80, null: false

      t.integer :wip_limit, null: false
      t.integer :current_wip, null: false

      t.integer :project_monte_carlo_weeks_p80, null: false
      t.integer :team_monte_carlo_weeks_p80, null: false

      t.decimal :flow_pressure, null: false
      t.decimal :flow_pressure_percentage, null: false

      t.decimal :customer_happiness, null: false

      t.timestamps
    end

    add_foreign_key :project_consolidations, :projects, column: :project_id
  end
end
