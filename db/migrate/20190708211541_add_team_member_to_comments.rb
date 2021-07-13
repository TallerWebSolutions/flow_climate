# frozen_string_literal: true

class AddTeamMemberToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :demand_comments, :team_member_id, :integer
    add_index :demand_comments, :team_member_id

    add_foreign_key :demand_comments, :team_members, column: :team_member_id
  end
end
