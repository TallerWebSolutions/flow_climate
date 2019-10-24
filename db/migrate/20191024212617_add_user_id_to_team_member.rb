# frozen_string_literal: true

class AddUserIdToTeamMember < ActiveRecord::Migration[6.0]
  def change
    add_column :team_members, :user_id, :integer, index: true
    add_foreign_key :team_members, :users, column: :user_id
  end
end
