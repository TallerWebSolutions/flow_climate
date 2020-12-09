# frozen_string_literal: true

class AddHoursScopeCacheToProjectConsolidation < ActiveRecord::Migration[6.0]
  def change
    change_table :project_consolidations, bulk: true do |t|
      t.integer :project_scope_hours, default: 0
      t.decimal :project_throughput_hours, default: 0

      t.decimal :project_throughput_hours_upstream, default: 0
      t.decimal :project_throughput_hours_downstream, default: 0
    end
  end
end
