# frozen_string_literal: true

class CreateProjectRiskAlerts < ActiveRecord::Migration[5.1]
  def change
    create_table :project_risk_alerts do |t|
      t.integer :project_id, null: false, index: true
      t.integer :project_risk_config_id, null: false, index: true

      t.integer :alert_color, null: false
      t.decimal :alert_value, null: false

      t.timestamps
    end

    add_foreign_key :project_risk_alerts, :projects, column: :project_id
    add_foreign_key :project_risk_alerts, :project_risk_configs, column: :project_risk_config_id
  end
end
