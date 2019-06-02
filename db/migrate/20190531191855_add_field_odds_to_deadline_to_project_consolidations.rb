# frozen_string_literal: true

class AddFieldOddsToDeadlineToProjectConsolidations < ActiveRecord::Migration[5.2]
  def up
    change_table :project_consolidations, bulk: true do |t|
      t.float :odds_to_deadline_project
      t.float :odds_to_deadline_team

      t.integer :min_weeks_montecarlo_project
      t.integer :min_weeks_montecarlo_team

      t.integer :max_weeks_montecarlo_project
      t.integer :max_weeks_montecarlo_team

      t.float :std_dev_weeks_montecarlo_project
      t.float :std_dev_weeks_montecarlo_team
    end
  end

  def down
    change_table :project_consolidations, bulk: true do |t|
      t.remove :odds_to_deadline

      t.remove :min_weeks_montecarlo_project
      t.remove :min_weeks_montecarlo_team

      t.remove :max_weeks_montecarlo_project
      t.remove :max_weeks_montecarlo_team

      t.remove :std_dev_weeks_montecarlo_project
      t.remove :std_dev_weeks_montecarlo_team
    end
  end
end
