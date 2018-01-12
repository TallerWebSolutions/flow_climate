# frozen_string_literal: true

class CreateOperationWeeklyResults < ActiveRecord::Migration[5.1]
  def change
    create_table :operation_weekly_results do |t|
      t.integer :company_id, null: false
      t.date :result_date, null: false
      t.integer :billable_count, null: false
      t.decimal :operation_week_value, null: false

      t.timestamps
    end

    add_foreign_key :operation_weekly_results, :companies, column: :company_id
  end
end
