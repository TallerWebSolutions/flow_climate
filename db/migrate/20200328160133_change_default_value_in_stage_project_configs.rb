# frozen_string_literal: true

class ChangeDefaultValueInStageProjectConfigs < ActiveRecord::Migration[6.0]
  def change
    change_column_null :stage_project_configs, :pairing_percentage, false
    change_column_null :stage_project_configs, :stage_percentage, false
    change_column_null :stage_project_configs, :management_percentage, false
  end
end
