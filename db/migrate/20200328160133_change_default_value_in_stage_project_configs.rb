# frozen_string_literal: true

class ChangeDefaultValueInStageProjectConfigs < ActiveRecord::Migration[6.0]
  # rubocop:disable Rails/BulkChangeTable
  def change
    change_column_null :stage_project_configs, :pairing_percentage, false
    change_column_null :stage_project_configs, :stage_percentage, false
    change_column_null :stage_project_configs, :management_percentage, false
  end
  # rubocop:enable Rails/BulkChangeTable
end
