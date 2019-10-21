# frozen_string_literal: true

class AddNewStatsFieldsToProjectConsolidation < ActiveRecord::Migration[6.0]
  def change
    change_table :project_consolidations, bulk: true do |t|
      t.integer :demands_finished_in_week, array: true, index: true
      t.decimal :lead_time_in_week, array: true, index: true
    end
  end
end
