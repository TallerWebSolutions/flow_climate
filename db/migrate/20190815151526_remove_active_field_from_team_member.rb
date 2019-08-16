# frozen_string_literal: true

class RemoveActiveFieldFromTeamMember < ActiveRecord::Migration[5.2]
  def change
    remove_column :team_members, :active, :boolean
  end
end
