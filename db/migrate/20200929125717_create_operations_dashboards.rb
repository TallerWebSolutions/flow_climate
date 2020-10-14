# frozen_string_literal: true

class CreateOperationsDashboards < ActiveRecord::Migration[6.0]
  def change
    create_table :operations_dashboards do |t|
      t.date :dashboard_date, null: false
      t.boolean :last_data_in_week, null: false, default: false
      t.boolean :last_data_in_month, null: false, default: false
      t.boolean :last_data_in_year, null: false, default: false

      t.integer :team_member_id, null: false, index: true
      t.integer :demands_ids, array: true
      t.integer :first_delivery_id

      t.integer :delivered_demands_count, null: false, default: 0
      t.integer :bugs_count, null: false, default: 0
      t.decimal :lead_time_min, null: false, default: 0
      t.decimal :lead_time_max, null: false, default: 0
      t.decimal :lead_time_p80, null: false, default: 0
      t.integer :projects_count, null: false, default: 0
      t.decimal :member_effort
      t.integer :pull_interval

      t.timestamps
    end

    add_foreign_key :operations_dashboards, :team_members, column: :team_member_id
    add_foreign_key :operations_dashboards, :demands, column: :first_delivery_id

    add_index :operations_dashboards, %i[team_member_id dashboard_date], unique: true, name: 'operations_dashboard_cache_unique'

    create_table :operations_dashboard_pairings do |t|
      t.integer :operations_dashboard_id, null: false, index: true
      t.integer :pair_id, null: false, index: true
      t.integer :pair_times, null: false

      t.timestamps
    end

    add_foreign_key :operations_dashboard_pairings, :operations_dashboards, column: :operations_dashboard_id
    add_foreign_key :operations_dashboard_pairings, :team_members, column: :pair_id

    add_index :operations_dashboard_pairings, %i[operations_dashboard_id pair_id], unique: true, name: 'operations_dashboard_pairings_cache_unique'
  end
end
