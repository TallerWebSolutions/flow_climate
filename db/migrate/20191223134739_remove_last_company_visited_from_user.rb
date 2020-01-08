# frozen_string_literal: true

class RemoveLastCompanyVisitedFromUser < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :last_company_id, :integer

    execute('UPDATE team_members SET user_id = (SELECT id FROM users u WHERE u.email = team_members.jira_account_user_email)')
  end

  def down
    add_column :users, :last_company_id, :integer
  end
end
