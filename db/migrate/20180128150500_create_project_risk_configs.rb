# frozen_string_literal: true

class CreateProjectRiskConfigs < ActiveRecord::Migration[5.1]
  def up
    create_table :project_risk_configs do |t|
      t.integer :company_id, index: true, null: false
      t.integer :risk_type, null: false
      t.decimal :high_yellow_value, null: false
      t.decimal :low_yellow_value, null: false

      t.timestamps
    end

    add_foreign_key :project_risk_configs, :companies, column: :company_id, index: true
  end

  def down
    drop_table :project_risk_configs
  end
end
