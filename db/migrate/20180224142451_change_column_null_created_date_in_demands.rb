# frozen_string_literal: true

class ChangeColumnNullCreatedDateInDemands < ActiveRecord::Migration[5.1]
  def change
    change_column_null :demands, :created_date, true
    change_column_null :demands, :project_result_id, true
    change_column_null :demands, :effort, true

    add_column :demands, :project_id, :integer, index: true
    add_foreign_key :demands, :projects, column: :project_id

    Demand.all.each do |demand|
      project = demand.project_result.project
      demand.update(project_id: project.id)
    end

    change_column_null :demands, :project_id, false
  end
end
