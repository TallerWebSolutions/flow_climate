# frozen_string_literal: true

class RemoveNotNullConstraintsFromProjectConsolidation < ActiveRecord::Migration[5.2]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.change :current_wip, :integer, null: true
      t.change :customer_happiness, :decimal, null: true
      t.change :demands_finished_ids, :integer, array: true, null: true
      t.change :demands_ids, :integer, array: true, null: true
      t.change :demands_lead_times, :decimal, array: true, null: true
      t.change :demands_lead_times_average, :decimal, null: true
      t.change :demands_lead_times_std_dev, :decimal, null: true
      t.change :flow_pressure, :decimal, null: true
      t.change :flow_pressure_percentage, :decimal, null: true
      t.change :histogram_range, :decimal, null: true
      t.change :interquartile_range, :decimal, null: true
      t.change :last_lead_time_p80, :decimal, null: true
      t.change :last_throughput_per_week_data, :integer, array: true, null: true
      t.change :lead_time_histogram_bin_max, :decimal, null: true
      t.change :lead_time_histogram_bin_min, :decimal, null: true
      t.change :lead_time_max, :decimal, null: true
      t.change :lead_time_min, :decimal, null: true
      t.change :lead_time_p25, :decimal, null: true
      t.change :lead_time_p75, :decimal, null: true
      t.change :population_end_date, :date, null: true
      t.change :population_start_date, :date, null: true
      t.change_default :project_aging, 0
      t.change :project_monte_carlo_weeks_p80, :decimal, null: true
      t.change :team_monte_carlo_weeks_p80, :decimal, null: true
      t.change :total_range, :decimal, null: true
      t.change_default :weeks_to_deadline, 0
      t.change :wip_limit, :integer, null: true
    end
  end
end
