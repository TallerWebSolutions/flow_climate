# frozen_string_literal: true

class CreateDemands < ActiveRecord::Migration[5.1]
  def up
    create_table :demands do |t|
      t.integer :project_result_id, null: false, index: true
      t.string :demand_id, null: false
      t.decimal :effort, null: false

      t.timestamps
    end

    change_table :project_results, bulk: true do |t|
      t.remove :demands_ids
      t.integer :demands_count
    end
  end

  def down
    drop_table :demands

    change_table :project_results, bulk: true do |t|
      t.string :demands_ids
      t.remove :demands_count
    end
  end
end
