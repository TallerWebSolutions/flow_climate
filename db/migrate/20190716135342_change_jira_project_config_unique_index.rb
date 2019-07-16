# frozen_string_literal: true

class ChangeJiraProjectConfigUniqueIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :jira_project_configs, %i[project_id fix_version_name]

    add_index :jira_project_configs, %i[jira_product_config_id fix_version_name], unique: true, name: 'unique_fix_version_to_jira_product'
  end

  def down
    # we cannot revert the index because the database may have dirty data

    # remove_index :jira_project_configs, %i[jira_product_config_id fix_version_name]
    # add_index :jira_project_configs, %i[project_id fix_version_name], unique: true
  end
end
