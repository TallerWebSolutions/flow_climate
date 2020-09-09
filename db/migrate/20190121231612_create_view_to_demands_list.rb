# frozen_string_literal: true

class CreateViewToDemandsList < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL.squish
      CREATE VIEW demands_lists
      AS
      SELECT d.id,
             d.demand_id,
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
             d.class_of_service,
             d.effort_upstream,
             d.effort_downstream,
             d.leadtime,
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

  def down
    execute 'DROP VIEW demands_lists'
  end
end
