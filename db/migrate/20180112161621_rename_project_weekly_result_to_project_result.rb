# frozen_string_literal: true

class RenameProjectWeeklyResultToProjectResult < ActiveRecord::Migration[5.1]
  def change
    rename_table :project_weekly_results, :project_results
  end
end
