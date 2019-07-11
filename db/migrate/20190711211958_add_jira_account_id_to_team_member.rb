# frozen_string_literal: true

class AddJiraAccountIdToTeamMember < ActiveRecord::Migration[5.2]
  def change
    add_column :team_members, :jira_account_id, :string, index: true
  end
end
