# frozen_string_literal: true

class CreateInitiativeConsolidations < ActiveRecord::Migration[6.1]
  def change
    create_table :initiative_consolidations do |t|
      t.integer :initiative_id, null: false, index: true
      t.date :consolidation_date, null: false, index: true

      t.boolean :last_data_in_week, default: false, null: false
      t.boolean :last_data_in_month, default: false, null: false
      t.boolean :last_data_in_year, default: false, null: false

      t.integer :tasks_delivered
      t.integer :tasks_delivered_in_month
      t.integer :tasks_delivered_in_week

      t.decimal :tasks_operational_risk
      t.integer :tasks_scope

      t.decimal :tasks_completion_time_p80
      t.decimal :tasks_completion_time_p80_in_month
      t.decimal :tasks_completion_time_p80_in_week

      t.timestamps
    end

    add_foreign_key :initiative_consolidations, :initiatives, column: :initiative_id
    add_index :initiative_consolidations, %i[initiative_id consolidation_date], unique: true, name: :initiative_consolidation_unique
  end
end
