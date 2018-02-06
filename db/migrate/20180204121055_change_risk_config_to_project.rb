# frozen_string_literal: true

class ChangeRiskConfigToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :project_risk_configs, :project_id, :integer, index: true, null: false
    remove_column :project_risk_configs, :company_id, :integer
  end
end
