# frozen_string_literal: true

class AddHabtmToCustomersProjects < ActiveRecord::Migration[5.2]
  def up
    create_table :customers_projects do |t|
      t.integer :customer_id, index: true, null: false
      t.integer :project_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :customers_projects, :customers, column: :customer_id
    add_foreign_key :customers_projects, :projects, column: :project_id

    add_index :customers_projects, %i[customer_id project_id], unique: true

    add_index :stages_teams, %i[stage_id team_id], unique: true

    change_table :projects, bulk: true do |t|
      t.integer :company_id, index: true
    end

    add_foreign_key :projects, :companies, column: :company_id

    execute('INSERT INTO customers_projects(customer_id, project_id, created_at, updated_at) SELECT customer_id, id, created_at, updated_at FROM projects')
    execute('UPDATE projects p SET company_id = subquery.company_id FROM (SELECT id, company_id FROM customers) AS subquery WHERE p.customer_id = subquery.id')

    change_column_null :projects, :company_id, false

    change_table :projects, bulk: true do |t|
      t.remove :customer_id
    end
  end

  def down
    change_table :projects, bulk: true do |t|
      t.integer :customer_id, index: true
    end

    add_foreign_key :projects, :customers, column: :customer_id

    drop_table :customers_projects
  end
end
