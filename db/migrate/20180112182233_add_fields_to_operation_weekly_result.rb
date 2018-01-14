# frozen_string_literal: true

class AddFieldsToOperationWeeklyResult < ActiveRecord::Migration[5.1]
  def change
    add_column :operation_weekly_results, :available_hours, :integer, null: false
    add_column :operation_weekly_results, :delivered_hours, :integer, null: false
    add_column :operation_weekly_results, :total_th, :integer, null: false
    add_column :operation_weekly_results, :total_opened_bugs, :integer, null: false
    add_column :operation_weekly_results, :total_accumulated_closed_bugs, :integer, null: false

    rename_column :operation_weekly_results, :billable_count, :people_billable_count
  end
end
