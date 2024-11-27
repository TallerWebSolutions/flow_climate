# frozen_string_literal: true

class RemoveTasksFromProjectConsolidation < ActiveRecord::Migration[8.0]
  def change
    change_table :project_consolidations, bulk: true do |t|
      t.remove :tasks_based_operational_risk, type: :decimal
      t.remove :tasks_based_deadline_p80, type: :decimal
    end
  end
end
