# frozen_string_literal: true

class CreateProjectBrokenWipLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :project_broken_wip_logs do |t|
      t.integer :project_id, null: false, index: true
      t.integer :project_wip, null: false
      t.integer :demands_ids, null: false, array: true

      t.timestamps
    end

    add_foreign_key :project_broken_wip_logs, :projects, column: :project_id
  end
end
