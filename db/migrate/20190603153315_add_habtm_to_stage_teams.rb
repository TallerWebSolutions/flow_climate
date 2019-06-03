# frozen_string_literal: true

class AddHabtmToStageTeams < ActiveRecord::Migration[5.2]
  def up
    change_table :stages, bulk: true do |t|
      t.remove :team_id
    end

    create_table :stages_teams do |t|
      t.integer :stage_id, index: true, null: false
      t.integer :team_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :stages_teams, :stages, column: :stage_id
    add_foreign_key :stages_teams, :teams, column: :team_id
  end

  def down
    change_table :stages, bulk: true do |t|
      t.integer :team_id
    end

    drop_table :stages_teams
  end
end
