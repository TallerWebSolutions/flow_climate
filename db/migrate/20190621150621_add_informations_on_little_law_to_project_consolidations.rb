# frozen_string_literal: true

class AddInformationsOnLittleLawToProjectConsolidations < ActiveRecord::Migration[5.2]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.integer :remaining_scope, default: 0

      t.integer :throughput_per_week_data, array: true
      t.decimal :throughput_average, default: 0
      t.decimal :throughput_std_dev, default: 0

      t.rename :last_throughput_per_week_data, :last_8_throughput_per_week_data

      t.decimal :last_8_throughput_average, default: 0
      t.decimal :last_8_throughput_std_dev, default: 0

      t.decimal :all_data_little_law_weeks, default: 0
      t.decimal :last_8_data_little_law_weeks, default: 0

      t.decimal :min_weeks_montecarlo_project_percentage, default: 0

      t.decimal :min_weeks_montecarlo_team_percentage, default: 0
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.remove :remaining_scope

      t.remove :throughput_per_week_data
      t.remove :throughput_average
      t.remove :throughput_std_dev

      t.rename :last_8_throughput_per_week_data, :last_throughput_per_week_data

      t.remove :last_8_throughput_average
      t.remove :last_8_throughput_std_dev

      t.remove :all_data_little_law_weeks
      t.remove :last_8_data_little_law_weeks

      t.remove :max_weeks_montecarlo_project_percentage
      t.remove :min_weeks_montecarlo_project_percentage

      t.remove :max_weeks_montecarlo_team_percentage
      t.remove :min_weeks_montecarlo_team_percentage
    end
  end
end
