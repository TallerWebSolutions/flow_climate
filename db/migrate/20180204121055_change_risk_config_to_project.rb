# frozen_string_literal: true

class ChangeRiskConfigToProject < ActiveRecord::Migration[5.1]
  def up
    change_table :project_risk_configs, bulk: true do |t|
      t.integer :project_id, index: true, null: false
      t.remove :company_id
    end
  end

  def down
    change_table :project_risk_configs, bulk: true do |t|
      t.remove :project_id
      t.integer :company_id
    end
  end
end
