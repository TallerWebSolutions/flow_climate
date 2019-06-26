# frozen_string_literal: true

class CreateJiraProductConfigs < ActiveRecord::Migration[5.2]
  def up
    create_table :jira_product_configs do |t|
      t.integer :company_id, null: false, index: true
      t.integer :product_id, null: false, index: true
      t.string :jira_product_key, null: false

      t.timestamps
    end

    add_foreign_key :jira_product_configs, :companies, column: :company_id
    add_foreign_key :jira_product_configs, :products, column: :product_id

    add_index :jira_product_configs, %i[company_id jira_product_key], unique: true

    execute <<-SQL
      INSERT INTO jira_product_configs(company_id, product_id, jira_product_key, created_at, updated_at)
      SELECT proj.company_id, prod_proj.product_id, proj_jira.jira_project_key, proj_jira.created_at, proj_jira.updated_at
      FROM products_projects prod_proj, project_jira_configs proj_jira, projects proj
      WHERE prod_proj.project_id = proj_jira.project_id
      AND proj.id = prod_proj.project_id
    SQL

    rename_table :project_jira_configs, :jira_project_configs

    change_table :jira_project_configs, bulk: true do |t|
      t.integer :jira_product_config_id, index: true

      t.change :fix_version_name, :string, null: false
    end
    add_foreign_key :jira_project_configs, :jira_product_configs, column: :jira_product_config_id

    Jira::JiraProjectConfig.all.each do |project_config|
      project_config.update(jira_product_config_id: Jira::JiraProductConfig.where(jira_product_key: project_config.jira_project_key).first.id)
    end

    # execute('UPDATE jira_project_configs proj_config SET jira_product_config_id = subquery.id FROM (SELECT id, jira_product_key FROM jira_product_configs) AS subquery WHERE proj_config.jira_project_key = subquery.jira_product_key')

    change_table :jira_project_configs, bulk: true do |t|
      t.remove :jira_project_key
      t.change :jira_product_config_id, :integer, null: false
    end

    add_index :jira_project_configs, %i[project_id fix_version_name], unique: true
  end

  def down
    remove_index :jira_project_configs, %i[project_id fix_version_name]

    change_table :project_jira_configs, bulk: true do |t|
      t.integer :jira_project_key
      t.change :fix_version_name, :string, null: true
    end

    add_index :jira_project_configs, %(project_id jira_project_key), unique: true
    remove_index :jira_product_configs, %i[product_id jira_product_key]

    drop_table :jira_product_configs

    rename_table :jira_project_configs, :project_jira_configs
  end
end
