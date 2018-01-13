# frozen_string_literal: true

class RenameOperationWeeklyResultToOperationResult < ActiveRecord::Migration[5.1]
  def change
    rename_table :operation_weekly_results, :operation_results
  end
end
