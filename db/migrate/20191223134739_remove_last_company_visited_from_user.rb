# frozen_string_literal: true

class RemoveLastCompanyVisitedFromUser < ActiveRecord::Migration[6.0]
  def up
    execute('UPDATE team_members SET user_id = (SELECT id FROM users u WHERE u.email = team_members.jira_account_user_email)')
  end

  def down; end
end
