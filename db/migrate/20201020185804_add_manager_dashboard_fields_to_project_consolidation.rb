# frozen_string_literal: true

class AddManagerDashboardFieldsToProjectConsolidation < ActiveRecord::Migration[6.0]
  def up
    execute('DELETE FROM project_consolidations')

    change_table :project_consolidations, bulk: true do |t|
      t.boolean :last_data_in_week, null: false, default: false
      t.boolean :last_data_in_month, null: false, default: false
      t.boolean :last_data_in_year, null: false, default: false

      t.integer :project_scope, default: 0
      t.decimal :flow_pressure, default: 0
      t.decimal :project_quality, default: 0
      t.decimal :value_per_demand, default: 0

      t.integer :monte_carlo_weeks_min, default: 0
      t.integer :monte_carlo_weeks_max, default: 0
      t.integer :monte_carlo_weeks_std_dev, default: 0
      t.decimal :monte_carlo_weeks_p80, default: 0
      t.decimal :operational_risk, default: 0

      t.integer :team_based_monte_carlo_weeks_min, default: 0
      t.integer :team_based_monte_carlo_weeks_max, default: 0
      t.integer :team_based_monte_carlo_weeks_std_dev, default: 0
      t.decimal :team_based_monte_carlo_weeks_p80, default: 0
      t.decimal :team_based_operational_risk, default: 0

      t.decimal :lead_time_min, default: 0
      t.decimal :lead_time_max, default: 0
      t.decimal :lead_time_p25, default: 0
      t.decimal :lead_time_p75, default: 0
      t.decimal :lead_time_p80, default: 0
      t.decimal :lead_time_average, default: 0
      t.decimal :lead_time_std_dev, default: 0
      t.decimal :lead_time_histogram_bin_min, default: 0
      t.decimal :lead_time_histogram_bin_max, default: 0

      t.decimal :weeks_by_little_law, default: 0

      t.remove :lead_time_in_week
      t.remove :project_monte_carlo_weeks
      t.remove :project_weekly_throughput
      t.integer :project_throughput, default: 0

      t.remove :team_monte_carlo_weeks
      t.remove :team_weekly_throughput

      t.remove :population_start_date
      t.remove :population_end_date
      t.remove :demands_finished_in_week
      t.remove :demands_lead_times
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.remove(:project_scope, :operational_risk, :flow_pressure, :project_throughput, :lead_time_p80, :project_quality, :value_per_demand, :last_data_in_week,
               :last_data_in_month, :last_data_in_year, :monte_carlo_weeks_min, :monte_carlo_weeks_max, :monte_carlo_weeks_std_dev, :team_based_operational_risk,
               :team_based_monte_carlo_weeks_min, :team_based_monte_carlo_weeks_max, :team_based_monte_carlo_weeks_std_dev, :monte_carlo_weeks_p80,
               :team_based_monte_carlo_weeks_p80, :lead_time_p25, :lead_time_p75, :lead_time_average, :lead_time_histogram_bin_min,
               :lead_time_histogram_bin_max, :lead_time_std_dev, :lead_time_min, :lead_time_max, :weeks_by_little_law)

      t.decimal :lead_time_in_week, array: true
      t.decimal :demands_lead_times, array: true
      t.integer :project_weekly_throughput, array: true
      t.integer :team_monte_carlo_weeks, array: true
      t.integer :team_weekly_throughput, array: true
      t.integer :project_monte_carlo_weeks, array: true

      t.datetime :population_start_date
      t.datetime :population_end_date

      t.integer :demands_finished_in_week, array: true
    end
  end
end
