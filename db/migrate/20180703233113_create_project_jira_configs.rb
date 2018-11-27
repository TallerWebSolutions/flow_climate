# frozen_string_literal: true

class CreateProjectJiraConfigs < ActiveRecord::Migration[5.2]
  def up
    create_table :jira_accounts do |t|
      t.integer :company_id, index: true, null: false
      t.string :username, null: false
      t.string :encrypted_password, null: false
      t.string :encrypted_password_iv, null: false
      t.string :base_uri, null: false
      t.string :customer_domain, null: false

      t.timestamps
    end
    add_foreign_key :jira_accounts, :companies, column: :company_id
    add_index :jira_accounts, :customer_domain, unique: true

    create_table :jira_custom_field_mappings do |t|
      t.integer :jira_account_id, index: true, null: false
      t.integer :demand_field, null: false
      t.string :custom_field_machine_name, null: false

      t.timestamps
    end
    add_foreign_key :jira_custom_field_mappings, :jira_accounts, column: :jira_account_id
    add_index :jira_custom_field_mappings, %i[jira_account_id demand_field], unique: true, name: 'unique_custom_field_to_jira_account'

    create_table :project_jira_configs do |t|
      t.integer :project_id, index: true, null: false
      t.integer :team_id, index: true, null: false

      t.string :jira_account_domain, null: false, index: true
      t.string :jira_project_key, null: false, index: true

      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :project_jira_configs, %i[jira_project_key jira_account_domain], unique: true, name: 'unique_jira_project_key_to_jira_account_domain'

    add_foreign_key :project_jira_configs, :projects, column: :project_id
    add_foreign_key :project_jira_configs, :teams, column: :team_id
  end

  def down
    drop_table :project_jira_configs
    drop_table :jira_custom_field_mappings
    drop_table :jira_accounts
  end
end
