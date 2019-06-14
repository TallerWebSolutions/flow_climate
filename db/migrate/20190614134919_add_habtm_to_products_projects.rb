# frozen_string_literal: true

class AddHabtmToProductsProjects < ActiveRecord::Migration[5.2]
  def up
    execute 'DROP VIEW demands_lists'

    execute <<-SQL
      CREATE VIEW demands_lists
      AS
      SELECT d.id, d.demand_id, d.slug, proj.id AS project_id, d.created_date, d.commitment_date, d.end_date, proj.name AS project_name, d.artifact_type, d.demand_type, d.demand_title, d.class_of_service, d.effort_upstream, d.effort_downstream, d.leadtime, d.total_queue_time, d.total_touch_time, d.url, d.discarded_at,
             count(DISTINCT blocks.id) AS blocks_count,
             SUM(EXTRACT(EPOCH FROM (blocks.unblock_time - blocks.block_time))) AS blocked_time,
             (SELECT SUM(EXTRACT(EPOCH FROM (queued_transitions.last_time_out - queued_transitions.last_time_in))) FROM demand_transitions queued_transitions, stages s WHERE queued_transitions.demand_id = d.id AND s.id = queued_transitions.stage_id AND s.queue = true) AS queued_time,
             (SELECT SUM(EXTRACT(EPOCH FROM (touch_transitions.last_time_out - touch_transitions.last_time_in))) FROM demand_transitions touch_transitions, stages s WHERE touch_transitions.demand_id = d.id AND s.id = touch_transitions.stage_id AND s.queue = false) AS touch_time
      FROM demands d
      INNER JOIN projects proj ON d.project_id = proj.id
      LEFT JOIN demand_blocks blocks ON blocks.demand_id = d.id
                       AND blocks.unblock_time >= blocks.block_time
                       AND blocks.active = TRUE
                       AND blocks.unblock_time IS NOT NULL
      GROUP BY d.id, proj.id
    SQL

    create_table :products_projects do |t|
      t.integer :product_id, index: true, null: false
      t.integer :project_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :products_projects, :products, column: :product_id
    add_foreign_key :products_projects, :projects, column: :project_id

    add_index :products_projects, %i[product_id project_id], unique: true

    execute('INSERT INTO products_projects(product_id, project_id, created_at, updated_at) SELECT product_id, id, created_at, updated_at FROM projects')

    change_table :projects, bulk: true do |t|
      t.remove :product_id
    end

    change_table :products, bulk: true do |t|
      t.remove :projects_count
    end
  end

  def down
    change_table :products, bulk: true do |t|
      t.integer :projects_count
    end

    change_table :projects, bulk: true do |t|
      t.integer :product_id, index: true
    end

    add_foreign_key :projects, :products, column: :product_id

    drop_table :products_projects

    execute 'DROP VIEW demands_lists'

    execute <<-SQL
      CREATE VIEW demands_lists
      AS
      SELECT d.id,
             d.demand_id,
             d.slug,
             proj.id AS project_id,
             prod.id AS product_id,
             cust.id AS customer_id,
             d.created_date,
             d.commitment_date,
             d.end_date,
             prod.name AS product_name,
             proj.name AS project_name,
             d.artifact_type,
             d.demand_type,
             d.demand_title,
             d.class_of_service,
             d.effort_upstream,
             d.effort_downstream,
             d.leadtime,
             d.total_queue_time,
             d.total_touch_time,
             d.url,
             d.discarded_at,
             count(DISTINCT blocks.id) AS blocks_count,
             SUM(EXTRACT(EPOCH FROM (blocks.unblock_time - blocks.block_time))) AS blocked_time,
             (SELECT SUM(EXTRACT(EPOCH FROM (queued_transitions.last_time_out - queued_transitions.last_time_in))) FROM demand_transitions queued_transitions, stages s WHERE queued_transitions.demand_id = d.id AND s.id = queued_transitions.stage_id AND s.queue = true) AS queued_time,
             (SELECT SUM(EXTRACT(EPOCH FROM (touch_transitions.last_time_out - touch_transitions.last_time_in))) FROM demand_transitions touch_transitions, stages s WHERE touch_transitions.demand_id = d.id AND s.id = touch_transitions.stage_id AND s.queue = false) AS touch_time
      FROM demands d
      INNER JOIN projects proj ON d.project_id = proj.id
      INNER JOIN products prod ON proj.product_id = prod.id
      INNER JOIN customers cust ON prod.customer_id = cust.id
      LEFT JOIN demand_blocks blocks ON blocks.demand_id = d.id
                       AND blocks.unblock_time >= blocks.block_time
                       AND blocks.active = TRUE
                       AND blocks.unblock_time IS NOT NULL
      GROUP BY d.id,
               proj.id,
               prod.id,
               cust.id;
    SQL
  end
end
