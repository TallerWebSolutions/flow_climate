# frozen_string_literal: true

class ChangeColumnNullCreatedDateInDemands < ActiveRecord::Migration[5.1]
  def change
    change_column_null :demands, :created_date, true
    change_column_null :demands, :project_result_id, true
    change_column_null :demands, :effort, true

    add_column :demands, :project_id, :integer, index: true, null: false
    add_foreign_key :demands, :projects, column: :project_id
  end
end
