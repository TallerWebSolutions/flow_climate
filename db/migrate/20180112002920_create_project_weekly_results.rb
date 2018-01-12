# frozen_string_literal: true

class CreateProjectWeeklyResults < ActiveRecord::Migration[5.1]
  def change
    create_table :project_weekly_results do |t|
      t.integer :project_id, null: false, index: true
      t.date :result_date, null: false
      t.integer :qty_hours_upstream
      t.integer :qty_hours_downstream
      t.integer :throughput, null: false
      t.integer :qty_bugs_opened, null: false
      t.integer :qty_bugs_closed, null: false
      t.integer :qty_hours_bug, null: false

      t.decimal :leadtime
      t.decimal :histogram_first_mode
      t.decimal :histogram_second_mode

      t.timestamps
    end

    add_foreign_key :project_weekly_results, :projects, column: :project_id
  end
end
