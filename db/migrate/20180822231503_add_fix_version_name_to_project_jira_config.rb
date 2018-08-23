# frozen_string_literal: true

class AddFixVersionNameToProjectJiraConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :project_jira_configs, :fix_version_name, :string, index: true
  end
end
