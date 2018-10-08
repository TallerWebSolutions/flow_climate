# frozen_string_literal: true

class AddFixVersionToUniqueKeysInProjectJiraConfig < ActiveRecord::Migration[5.2]
  def up
    remove_index :project_jira_configs, column: %i[jira_project_key jira_account_domain]
    add_index :project_jira_configs, %i[jira_project_key jira_account_domain fix_version_name], unique: true, name: 'unique_jira_project_key_to_jira_account_domain'
  end

  def down
    remove_index :project_jira_configs, column: %i[jira_project_key jira_account_domain fix_version_name]
    add_index :project_jira_configs, %i[jira_project_key jira_account_domain], unique: true, name: 'unique_jira_project_key_to_jira_account_domain'
  end
end
