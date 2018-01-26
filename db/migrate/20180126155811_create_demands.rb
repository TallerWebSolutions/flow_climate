# frozen_string_literal: true

class CreateDemands < ActiveRecord::Migration[5.1]
  def change
    create_table :demands do |t|
      t.integer :project_result_id, null: false, index: true
      t.string :demand_id, null: false
      t.decimal :effort, null: false

      t.timestamps
    end

    remove_column :project_results, :demands_ids, :string

    add_column :project_results, :demands_count, :integer
  end
end
