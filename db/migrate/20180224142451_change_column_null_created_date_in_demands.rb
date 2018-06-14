# frozen_string_literal: true

class ChangeColumnNullCreatedDateInDemands < ActiveRecord::Migration[5.1]
  def up
    change_table :demands, bulk: true do |t|
      t.change :created_date, :datetime, null: true
      t.change :project_result_id, :integer, null: true
      t.change :effort, :decimal, null: true
      t.integer :project_id, index: true, null: false
    end

    add_foreign_key :demands, :projects, column: :project_id
  end

  def down
    remove_foreign_key :demands, :projects

    change_table :demands, bulk: true do |t|
      t.change :created_date, :datetime, null: false
      t.change :project_result_id, :integer, null: false
      t.change :effort, :decimal, null: false
      t.remove :project_id
    end
  end
end
