# frozen_string_literal: true

class DropInitiatives < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :projects, :initiatives, column: :initiative_id
    remove_column :projects, :initiative_id

    drop_table :initiative_consolidations

    drop_table :initiatives
  end

  def down
    create_table :initiatives do |t|
      t.integer :company_id, null: false, index: true
      t.integer :target_quarter, null: false, index: true
      t.string :name, null: false, index: true

      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    add_foreign_key :initiatives, :companies, column: :company_id
    add_index :initiatives, %i[company_id name], unique: true

    add_column :projects, :initiative_id, :integer
    add_foreign_key :projects, :initiatives, column: :initiative_id

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
