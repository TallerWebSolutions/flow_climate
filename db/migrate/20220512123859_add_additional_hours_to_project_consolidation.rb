# frozen_string_literal: true

class AddAdditionalHoursToProjectConsolidation < ActiveRecord::Migration[7.0]
  def change
    change_table :project_consolidations, bulk: true do |t|
      t.float :project_throughput_hours_additional
      t.float :project_throughput_hours_additional_in_month
    end
  end
end
