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
    execute('DROP TABLE pipefy_configs')
    execute('DROP TABLE pipefy_team_configs')

    remove_column :demands, :project_result_id

    drop_table :project_results
  end

  def down
    create_table :project_results do |t|
      t.boolean :active

      t.integer :project_id, null: false
      t.integer :team_id, null: false
      t.date :result_date, null: false

      t.integer :known_scope, null: false
      t.integer :qty_hours_upstream, null: false
      t.integer :qty_hours_downstream, null: false
      t.integer :qty_bugs_opened, null: false
      t.integer :qty_bugs_closed, null: false
      t.integer :qty_hours_bug, null: false

      t.integer :demands_count

      t.decimal :leadtime_95_confidence
      t.decimal :leadtime_80_confidence
      t.decimal :leadtime_60_confidence
      t.decimal :leadtime_average

      t.decimal :cost_in_month
      t.decimal :available_hours

      t.decimal :effort_share_in_month
      t.decimal :throughput_upstream
      t.decimal :throughput_downstream
      t.decimal :average_demand_cost
      t.decimal :remaining_days
      t.decimal :flow_pressure

      t.decimal :monte_carlo_date

      t.boolean :active
      t.boolean :manual_input

      t.timestamps
    end

    add_column :demands, :project_result_id, :integer
    add_index :demands, :project_result_id
    add_foreign_key :demands, :project_results, column: :project_result_id

    add_foreign_key :project_results, :teams, column: :team_id

    create_table :pipefy_configs do |t|
      t.integer :company_id, null: false
      t.integer :project_id, null: false
      t.integer :team_id, null: false
      t.string :pipe_id, null: false

      t.boolean :active

      t.timestamps
    end

    add_foreign_key :pipefy_configs, :companies, column: :company_id
    add_foreign_key :pipefy_configs, :projects, column: :project_id
    add_foreign_key :pipefy_configs, :teams, column: :team_id

    create_table :pipefy_team_configs do |t|
      t.integer :team_id, null: false
      t.string :integration_id, null: false
      t.string :username, null: false
      t.integer :member_type, default: 0

      t.timestamps
    end

    add_foreign_key :pipefy_team_configs, :teams, column: :team_id

    execute('DROP TABLE project_weekly_costs')
  end
end
