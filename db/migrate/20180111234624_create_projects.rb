# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.integer :customer_id, null: false, index: true
      t.string :name, null: false
      t.integer :status, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.decimal :value
      t.decimal :qty_hours
      t.decimal :hour_value
      t.integer :initial_scope, null: false

      t.timestamps
    end

    add_foreign_key :projects, :customers, column: :customer_id
  end
end
