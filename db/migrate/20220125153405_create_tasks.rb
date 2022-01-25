# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.integer :demand_id, null: false, index: true
      t.datetime :created_date, null: false
      t.string :title, null: false
      t.integer :external_id
      t.integer :seconds_to_complete
      t.datetime :end_date

      t.timestamps
    end

    add_foreign_key :tasks, :demands, column: :demand_id
  end
end
