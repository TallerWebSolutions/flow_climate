# frozen_string_literal: true

class ChangeAssigneesCountToAssigneesFullInfo < ActiveRecord::Migration[5.2]
  def up
    create_table :demands_team_members do |t|
      t.integer :demand_id, null: false, index: true
      t.integer :team_member_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :demands_team_members, :demands, column: :demand_id
    add_foreign_key :demands_team_members, :team_members, column: :team_member_id
  end

  def down
    drop_table :demands_team_members
  end
end
