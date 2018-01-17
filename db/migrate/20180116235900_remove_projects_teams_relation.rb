# frozen_string_literal: true

class RemoveProjectsTeamsRelation < ActiveRecord::Migration[5.1]
  def up
    drop_table :projects_teams
  end

  def down
    create_table :projects_teams do |t|
      t.integer :project_id, null: false, index: true
      t.integer :team_id, null: false, index: true
      t.timestamps
    end
  end
end
