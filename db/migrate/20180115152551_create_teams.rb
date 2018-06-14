# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[5.1]
  def up
    create_table :teams do |t|
      t.integer :company_id, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end
    add_foreign_key :teams, :companies, column: :company_id

    add_column :team_members, :team_id, :integer, null: false
    add_foreign_key :team_members, :teams, column: :team_id
    remove_column :team_members, :company_id, :integer

    create_table :projects_teams do |t|
      t.integer :project_id, null: false, index: true
      t.integer :team_id, null: false, index: true
      t.timestamps
    end
    add_foreign_key :projects_teams, :projects, column: :project_id
    add_foreign_key :projects_teams, :projects, column: :team_id
  end

  def down
    drop_table :projects_teams

    change_table :team_members, bulk: true do |t|
      t.remove :team_id
      t.integer :company_id
    end

    drop_table :teams
  end
end
