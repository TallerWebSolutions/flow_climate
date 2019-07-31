# frozen_string_literal: true

class AddHelperFieldsToProjectConsolidations < ActiveRecord::Migration[5.2]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.integer :project_weekly_throughput, array: true
      t.integer :team_weekly_throughput, array: true
      t.integer :products_weekly_throughput, array: true

      t.integer :project_monte_carlo_weeks, array: true
      t.integer :team_monte_carlo_weeks, array: true
      t.integer :products_monte_carlo_weeks, array: true

      t.remove :demands_lead_times_average
      t.remove :demands_lead_times_std_dev

      t.remove :lead_time_max
      t.remove :lead_time_min

      t.remove :total_range
      t.remove :histogram_range

      t.remove :lead_time_p25
      t.remove :lead_time_p75
      t.remove :interquartile_range

      t.remove :last_8_throughput_per_week_data
      t.remove :last_8_throughput_average
      t.remove :last_8_throughput_std_dev

      t.remove :throughput_per_week_data
      t.remove :throughput_average
      t.remove :throughput_std_dev

      t.remove :last_8_data_little_law_weeks
      t.remove :all_data_little_law_weeks

      t.remove :last_lead_time_p80
      t.remove :min_weeks_montecarlo_project
      t.remove :max_weeks_montecarlo_project
      t.remove :std_dev_weeks_montecarlo_project
      t.remove :odds_to_deadline_project

      t.remove :team_monte_carlo_weeks_p80
      t.remove :min_weeks_montecarlo_team
      t.remove :max_weeks_montecarlo_team
      t.remove :min_weeks_montecarlo_team_percentage
      t.remove :std_dev_weeks_montecarlo_team

      t.remove :weeks_to_deadline
      t.remove :project_aging
      t.remove :flow_pressure
      t.remove :flow_pressure_percentage

      t.remove :customer_happiness

      t.remove :lead_time_histogram_bin_max
      t.remove :lead_time_histogram_bin_min
      t.remove :remaining_scope
      t.remove :min_weeks_montecarlo_project_percentage
      t.remove :odds_to_deadline_team
      t.remove :project_monte_carlo_weeks_p80
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.remove :project_weekly_throughput
      t.remove :team_monte_carlo_weeks
      t.remove :products_weekly_throughput

      t.remove :project_monte_carlo_weeks
      t.remove :team_weekly_throughput
      t.remove :products_monte_carlo_weeks

      t.integer :project_aging, null: false
      t.integer :weeks_to_deadline, null: false

      t.decimal :lead_time_min, null: false
      t.decimal :lead_time_max, null: false
      t.decimal :total_range, null: false

      t.decimal :lead_time_histogram_bin_min, null: false
      t.decimal :lead_time_histogram_bin_max, null: false
      t.decimal :histogram_range, null: false

      t.decimal :lead_time_p25, null: false
      t.decimal :lead_time_p75, null: false
      t.decimal :interquartile_range, null: false

      t.integer :last_8_throughput_per_week_data, null: false, array: true
      t.decimal :last_lead_time_p80, null: false

      t.integer :project_monte_carlo_weeks_p80, null: false
      t.integer :team_monte_carlo_weeks_p80, null: false

      t.decimal :flow_pressure, null: false
      t.decimal :flow_pressure_percentage, null: false

      t.decimal :customer_happiness, null: false

      t.decimal :demands_lead_times_average
      t.decimal :demands_lead_times_std_dev
      t.decimal :last_8_throughput_average
      t.decimal :last_8_throughput_std_dev
      t.decimal :throughput_per_week_data
      t.decimal :throughput_average
      t.decimal :throughput_std_dev
      t.decimal :last_8_data_little_law_weeks
      t.decimal :all_data_little_law_weeks
      t.decimal :min_weeks_montecarlo_project
      t.decimal :max_weeks_montecarlo_project
      t.decimal :std_dev_weeks_montecarlo_project
      t.decimal :odds_to_deadline_project
      t.decimal :min_weeks_montecarlo_team
      t.decimal :max_weeks_montecarlo_team
      t.decimal :min_weeks_montecarlo_team_percentage
      t.decimal :std_dev_weeks_montecarlo_team
      t.integer :remaining_scope
      t.decimal :min_weeks_montecarlo_project_percentage
      t.decimal :odds_to_deadline_team
    end
  end
end
