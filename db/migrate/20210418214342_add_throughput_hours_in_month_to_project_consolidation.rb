# frozen_string_literal: true

class AddThroughputHoursInMonthToProjectConsolidation < ActiveRecord::Migration[6.1]
  def change
    change_table :project_consolidations, bulk: true do |t|
      t.decimal :project_throughput_hours_in_month
      t.decimal :project_throughput_hours_upstream_in_month
      t.decimal :project_throughput_hours_downstream_in_month
    end
  end
end
