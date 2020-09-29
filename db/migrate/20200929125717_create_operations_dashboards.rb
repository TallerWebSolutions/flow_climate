# frozen_string_literal: true

class CreateOperationsDashboards < ActiveRecord::Migration[6.0]
  def change
    create_table :operations_dashboards do |t|
      t.integer :team_member_id, null: false, index: true
      t.integer :first_delivery_id, null: false
      t.date :dashboard_date, null: false

      t.integer :delivered_demands_count, null: false, default: 0
      t.integer :bugs_count, null: false, default: 0
      t.decimal :lead_time_min, null: false, default: 0
      t.decimal :lead_time_max, null: false, default: 0
      t.decimal :lead_time_p80, null: false, default: 0
      t.integer :projects_count, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :operations_dashboards, :team_members, column: :team_member_id
    add_foreign_key :operations_dashboards, :demands, column: :first_delivery_id

    create_table :operations_dashboard_pairings do |t|
      t.integer :operations_dashboard_id, null: false, index: true
      t.integer :pair_id, null: false, index: true
      t.integer :pair_times, null: false

      t.timestamps
    end

    add_foreign_key :operations_dashboard_pairings, :operations_dashboards, column: :operations_dashboard_id
    add_foreign_key :operations_dashboard_pairings, :team_members, column: :pair_id
  end
end
