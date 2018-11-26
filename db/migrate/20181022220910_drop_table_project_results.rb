# frozen_string_literal: true

class DropTableProjectResults < ActiveRecord::Migration[5.2]
  def up
    create_table :project_weekly_costs do |t|
      t.integer :project_id, index: true
      t.date :date_beggining_of_week
      t.decimal :monthly_cost_value

      t.timestamps
    end

    add_foreign_key :project_weekly_costs, :projects, column: :project_id

    execute('INSERT INTO project_weekly_costs (id, project_id, monthly_cost_value, created_at, updated_at) SELECT id, project_id, cost_in_month, created_at, updated_at FROM project_results')
    execute('DROP TABLE pipefy_config')
    execute('DROP TABLE pipefy_team_config')

    drop_table :project_results

    remove_column :demands, :project_result_id
  end

  def down
    create_table :project_results do |t|
      t.integer :project_id, null: false, index: true
      t.date :result_date, null: false

      t.integer :known_scope, null: false
      t.integer :qty_hours_upstream, null: false
      t.integer :qty_hours_downstream, null: false
      t.integer :throughput, null: false
      t.integer :qty_bugs_opened, null: false
      t.integer :qty_bugs_closed, null: false
      t.integer :qty_hours_bug, null: false

      t.decimal :leadtime
      t.decimal :histogram_first_mode
      t.decimal :histogram_second_mode

      t.timestamps
    end

    add_column :project_result_id, :integer, null: false, index: true
    add_foreign_key :demands, :project_results, column: :project_result_id
  end
end
