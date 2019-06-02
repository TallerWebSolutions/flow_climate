# frozen_string_literal: true

class DropTableFlowConsolidations < ActiveRecord::Migration[5.2]
  def up
    drop_table :flow_consolidations
  end

  def down
    create_table :flow_consolidations do |t|
      t.date :consolidation_date, null: false

      t.date :population_start_date, null: false
      t.date :population_end_date, null: false

      t.integer :team_id, null: false, index: true
      t.integer :demands_ids, array: true, null: false
      t.integer :projects_ids, array: true, null: false

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

      t.decimal :average_customer_happiness, null: false

      t.decimal :flow_pressure, null: false
      t.decimal :flow_total_cost, null: false

      t.timestamps
    end

    add_foreign_key :flow_consolidations, :teams, column: :team_id
  end
end
