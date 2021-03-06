# frozen_string_literal: true

class AddTeamToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :team_id, :integer
    add_index :projects, :team_id
    add_foreign_key :projects, :teams, column: :team_id
  end
end
