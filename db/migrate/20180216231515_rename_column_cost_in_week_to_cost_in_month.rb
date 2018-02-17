# frozen_string_literal: true

class RenameColumnCostInWeekToCostInMonth < ActiveRecord::Migration[5.1]
  def change
    rename_column :project_results, :cost_in_week, :cost_in_month
  end
end
