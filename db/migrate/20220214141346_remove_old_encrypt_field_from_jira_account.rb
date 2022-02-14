# frozen_string_literal: true

class RemoveOldEncryptFieldFromJiraAccount < ActiveRecord::Migration[7.0]
  def change
    remove_column :jira_accounts, :encrypted_api_token_iv, :string
  end
end
