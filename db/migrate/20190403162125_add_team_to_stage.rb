# frozen_string_literal: true

class AddTeamToStage < ActiveRecord::Migration[5.2]
  def change
    change_table :stages, bulk: true do |t|
      t.integer :team_id, index: true
    end

    add_foreign_key :stages, :teams, column: :team_id
  end
end
