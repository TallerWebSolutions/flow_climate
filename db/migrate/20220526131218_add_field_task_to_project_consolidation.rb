class AddFieldTaskToProjectConsolidation < ActiveRecord::Migration[7.0]
  def change
    add_column :project_consolidations, :tasks_based_operational_risk_p80, :decimal
  end
end
