# frozen_string_literal: true

class CreateProjectJiraConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :jira_accounts do |t|
      t.integer :company_id, index: true, null: false
      t.string :username, null: false
      t.string :encrypted_password, null: false
      t.string :base_uri, null: false

      t.timestamps
    end
    add_foreign_key :jira_accounts, :companies, column: :company_id

    create_table :jira_custom_field_mappings do |t|
      t.integer :jira_account_id, index: true, null: false
      t.integer :demand_field, null: false
      t.string :custom_field_machine_name, null: false

      t.timestamps
    end
    add_foreign_key :jira_custom_field_mappings, :jira_accounts, column: :jira_account_id
    add_index :jira_custom_field_mappings, %i[jira_account_id demand_field], unique: true, name: 'unique_custom_field_to_jira_account'

    create_table :project_jira_configs do |t|
      t.integer :jira_account_id, index: true, null: false
      t.integer :project_id, index: true, null: false
      t.integer :team_id, index: true, null: false

      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_foreign_key :project_jira_configs, :jira_accounts, column: :jira_account_id
    add_foreign_key :project_jira_configs, :projects, column: :project_id
    add_foreign_key :project_jira_configs, :teams, column: :team_id

    add_column :projects, :integration_id, :string, index: true
  end
end
