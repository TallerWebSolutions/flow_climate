# frozen_string_literal: true

class ChangePasswordFieldNameInJiraAccount < ActiveRecord::Migration[5.2]
  def change
    rename_column :jira_accounts, :encrypted_password, :encrypted_api_token
    rename_column :jira_accounts, :encrypted_password_iv, :encrypted_api_token_iv
  end
end
