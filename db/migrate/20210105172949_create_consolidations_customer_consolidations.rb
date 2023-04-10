# frozen_string_literal: true

class CreateConsolidationsCustomerConsolidations < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_consolidations do |t|
      t.integer :customer_id, null: false, index: true
      t.date :consolidation_date, null: false

      t.boolean :last_data_in_week, default: false, index: true, null: false
      t.boolean :last_data_in_month, default: false, index: true, null: false
      t.boolean :last_data_in_year, default: false, index: true, null: false

      t.decimal :consumed_hours, default: 0
      t.decimal :consumed_hours_in_month, default: 0
      t.decimal :average_consumed_hours_in_month, default: 0
      t.decimal :flow_pressure, default: 0
      t.decimal :lead_time_p80, default: 0
      t.decimal :lead_time_p80_in_month, default: 0
      t.decimal :value_per_demand, default: 0
      t.decimal :value_per_demand_in_month, default: 0
      t.decimal :hours_per_demand, default: 0
      t.decimal :hours_per_demand_in_month, default: 0

      t.integer :qty_demands_created, default: 0
      t.integer :qty_demands_committed, default: 0
      t.integer :qty_demands_finished, default: 0

      t.timestamps
    end

    add_foreign_key :customer_consolidations, :customers, column: :customer_id
    add_index :customer_consolidations, %i[customer_id consolidation_date], unique: true, name: 'customer_consolidation_unique'
  end
end
