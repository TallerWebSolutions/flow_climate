# frozen_string_literal: true

class AddFieldsToOperationWeeklyResult < ActiveRecord::Migration[5.1]
  def change
    change_table :operation_weekly_results, bulk: true do |t|
      t.integer :available_hours, null: false
      t.integer :delivered_hours, null: false
      t.integer :total_th, null: false
      t.integer :total_opened_bugs, null: false
      t.integer :total_accumulated_closed_bugs, null: false
      t.rename :billable_count, :people_billable_count
    end
  end
end
