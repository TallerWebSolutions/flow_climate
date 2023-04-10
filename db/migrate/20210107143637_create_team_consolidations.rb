# frozen_string_literal: true

class CreateTeamConsolidations < ActiveRecord::Migration[6.1]
  # noinspection DuplicatedCode
  def change
    create_table :team_consolidations do |t|
      t.integer :team_id, null: false, index: true
      t.date :consolidation_date, null: false

      t.boolean :last_data_in_week, default: false, index: true, null: false
      t.boolean :last_data_in_month, default: false, index: true, null: false
      t.boolean :last_data_in_year, default: false, index: true, null: false

      t.decimal :consumed_hours_in_month, default: 0

      t.decimal :lead_time_p80, default: 0
      t.decimal :lead_time_p80_in_week, default: 0
      t.decimal :lead_time_p80_in_month, default: 0
      t.decimal :lead_time_p80_in_quarter, default: 0
      t.decimal :lead_time_p80_in_semester, default: 0
      t.decimal :lead_time_p80_in_year, default: 0

      t.decimal :flow_efficiency, default: 0
      t.decimal :flow_efficiency_in_month, default: 0
      t.decimal :flow_efficiency_in_quarter, default: 0
      t.decimal :flow_efficiency_in_semester, default: 0
      t.decimal :flow_efficiency_in_year, default: 0

      t.decimal :hours_per_demand, default: 0
      t.decimal :hours_per_demand_in_month, default: 0
      t.decimal :hours_per_demand_in_quarter, default: 0
      t.decimal :hours_per_demand_in_semester, default: 0
      t.decimal :hours_per_demand_in_year, default: 0

      t.decimal :value_per_demand, default: 0
      t.decimal :value_per_demand_in_month, default: 0
      t.decimal :value_per_demand_in_quarter, default: 0
      t.decimal :value_per_demand_in_semester, default: 0
      t.decimal :value_per_demand_in_year, default: 0

      t.integer :qty_demands_created, default: 0
      t.integer :qty_demands_created_in_week, default: 0

      t.integer :qty_demands_committed, default: 0
      t.integer :qty_demands_committed_in_week, default: 0

      t.integer :qty_demands_finished_upstream, default: 0
      t.integer :qty_demands_finished_upstream_in_week, default: 0
      t.integer :qty_demands_finished_upstream_in_month, default: 0
      t.integer :qty_demands_finished_upstream_in_quarter, default: 0
      t.integer :qty_demands_finished_upstream_in_semester, default: 0
      t.integer :qty_demands_finished_upstream_in_year, default: 0

      t.integer :qty_demands_finished_downstream, default: 0
      t.integer :qty_demands_finished_downstream_in_week, default: 0
      t.integer :qty_demands_finished_downstream_in_month, default: 0
      t.integer :qty_demands_finished_downstream_in_quarter, default: 0
      t.integer :qty_demands_finished_downstream_in_semester, default: 0
      t.integer :qty_demands_finished_downstream_in_year, default: 0

      t.integer :qty_bugs_opened, default: 0
      t.integer :qty_bugs_opened_in_month, default: 0
      t.integer :qty_bugs_opened_in_quarter, default: 0
      t.integer :qty_bugs_opened_in_semester, default: 0
      t.integer :qty_bugs_opened_in_year, default: 0

      t.integer :qty_bugs_closed, default: 0
      t.integer :qty_bugs_closed_in_month, default: 0
      t.integer :qty_bugs_closed_in_quarter, default: 0
      t.integer :qty_bugs_closed_in_semester, default: 0
      t.integer :qty_bugs_closed_in_year, default: 0

      t.decimal :bugs_share, default: 0
      t.decimal :bugs_share_in_month, default: 0
      t.decimal :bugs_share_in_quarter, default: 0
      t.decimal :bugs_share_in_semester, default: 0
      t.decimal :bugs_share_in_year, default: 0

      t.timestamps
    end

    add_foreign_key :team_consolidations, :teams, column: :team_id
    add_index :team_consolidations, %i[team_id consolidation_date], unique: true, name: 'team_consolidation_unique'
  end
end
