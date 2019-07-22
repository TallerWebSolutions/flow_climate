# frozen_string_literal: true

class AddComputedFieldsToOptimizeDemandCost < ActiveRecord::Migration[5.2]
  def up
    change_table :demands, bulk: true do |t|
      t.decimal :cost_to_project, default: 0
      t.decimal :blocked_working_time_downstream, default: 0
      t.decimal :blocked_working_time_upstream, default: 0
      t.decimal :total_bloked_working_time, default: 0
      t.decimal :total_touch_blocked_time, default: 0
    end

    Demand.all.map(&:save)
  end

  def down
    change_table :demands, bulk: true do |t|
      t.remove :cost_to_project
      t.remove :blocked_working_time_downstream
      t.remove :blocked_working_time_upstream
      t.remove :total_bloked_working_time
      t.remove :total_touch_blocked_time
    end
  end
end
