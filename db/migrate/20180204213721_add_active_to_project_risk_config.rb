# frozen_string_literal: true

class AddActiveToProjectRiskConfig < ActiveRecord::Migration[5.1]
  def change
    add_column :project_risk_configs, :active, :boolean, default: true, null: false
  end
end
