# frozen_string_literal: true

class AddHabtmToCustomersProjects < ActiveRecord::Migration[5.2]
  def up
    execute("UPDATE projects p SET name = (subquery.product_name || ' | ' || p.name) FROM (SELECT products.id AS product_id, products.name AS product_name, customers.company_id FROM products, customers WHERE customer_id = customers.id) AS subquery WHERE subquery.product_id = p.product_id AND subquery.company_id = 2 AND p.name = 'Sustentação - 2018-02'")
    execute("UPDATE projects p SET name = (subquery.product_name || ' | ' || p.name) FROM (SELECT products.id AS product_id, products.name AS product_name, customers.company_id FROM products, customers WHERE customer_id = customers.id) AS subquery WHERE subquery.product_id = p.product_id AND subquery.company_id = 1 AND p.name = 'Fase 1'")
    execute("UPDATE projects p SET name = (subquery.product_name || ' | ' || p.name) FROM (SELECT products.id AS product_id, products.name AS product_name, customers.company_id FROM products, customers WHERE customer_id = customers.id) AS subquery WHERE subquery.product_id = p.product_id AND subquery.company_id = 1 AND p.name = 'F1'")
    execute("UPDATE projects p SET name = (subquery.product_name || ' | ' || p.name) FROM (SELECT products.id AS product_id, products.name AS product_name, customers.company_id FROM products, customers WHERE customer_id = customers.id) AS subquery WHERE subquery.product_id = p.product_id AND subquery.company_id = 1 AND p.name = 'Fase 3'")
    execute("UPDATE projects p SET name = (subquery.product_name || ' | ' || p.name) FROM (SELECT products.id AS product_id, products.name AS product_name, customers.company_id FROM products, customers WHERE customer_id = customers.id) AS subquery WHERE subquery.product_id = p.product_id AND subquery.company_id = 1 AND p.name = 'Fase 2'")

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

    remove_index :projects, %i[product_id name]

    add_index :projects, %i[company_id name], unique: true

    change_table :demands, bulk: true do |t|
      t.change_default :assignees_count, from: nil, to: 0
    end
  end

  def down
    change_table :projects, bulk: true do |t|
      t.integer :customer_id, index: true
    end

    add_foreign_key :projects, :customers, column: :customer_id

    drop_table :customers_projects

    remove_index :projects, %i[company_id name]

    change_table :demands, bulk: true do |t|
      t.change_default :assignees_count, from: 0, to: nil
    end
  end
end
