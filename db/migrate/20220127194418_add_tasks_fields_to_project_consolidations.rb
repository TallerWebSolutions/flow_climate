# frozen_string_literal: true

class AddTasksFieldsToProjectConsolidations < ActiveRecord::Migration[6.1]
  def change
    change_table :project_consolidations, bulk: true do |t|
      t.decimal :tasks_based_operational_risk, default: 0
      t.decimal :tasks_based_deadline_p80, default: 0
    end
  end
end
