# frozen_string_literal: true

class AddTeamToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :team_id, :integer, null: false
    add_index :project_results, :team_id
    add_foreign_key :project_results, :teams, column: :team_id
  end
end
