# frozen_string_literal: true

class AddJiraAccountUserEmailToTeamMember < ActiveRecord::Migration[5.2]
  def up
    change_table :team_members, bulk: true do |t|
      t.string :jira_account_user_email, index: true
    end
  end

  def down
    change_table :team_members, bulk: true do |t|
      t.remove :jira_account_user_email
    end
  end
end
