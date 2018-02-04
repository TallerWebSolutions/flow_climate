# frozen_string_literal: true

class ChangeRiskConfigToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :project_risk_configs, :project_id, :integer, index: true
    change_column_null :project_risk_configs, :company_id, true

    ProjectRiskAlert.destroy_all

    ProjectRiskConfig.all.each do |risk|
      company_id = risk.company_id
      projects = Company.find(company_id).projects

      projects.each do |project|
        ProjectRiskConfig.create(project_id: project.id, risk_type: risk.risk_type, low_yellow_value: risk.low_yellow_value, high_yellow_value: risk.high_yellow_value)
      end

      risk.destroy
    end

    remove_column :project_risk_configs, :company_id, :integer
    change_column_null :project_risk_configs, :project_id, false
  end
end
