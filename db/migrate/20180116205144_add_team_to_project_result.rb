# frozen_string_literal: true

class AddTeamToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :team_id, :integer, index: true
    titanium = Team.find_by(id: 5)
    ProjectResult.all.each { |pr| pr.update(team_id: titanium.id) }

    change_column_null :project_results, :team_id, false

    add_foreign_key :project_results, :teams, column: :team_id
  end
end
