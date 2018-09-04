# frozen_string_literal: true

class DropTableOperationResults < ActiveRecord::Migration[5.2]
  def up
    drop_table :operation_results
  end

  def down
    create_table :operation_results do |t|
      t.integer :company_id, null: false
      t.date :result_date, null: false
      t.integer :billable_count, null: false
      t.decimal :operation_week_value, null: false

      t.timestamps
    end

    add_foreign_key :operation_results, :companies, column: :company_id
  end
end
