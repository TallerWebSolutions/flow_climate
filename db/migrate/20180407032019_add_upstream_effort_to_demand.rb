# frozen_string_literal: true

class AddUpstreamEffortToDemand < ActiveRecord::Migration[5.1]
  def up
    change_table :demands, bulk: true do |t|
      t.decimal :effort_downstream, default: 0
      t.decimal :effort_upstream, default: 0

      t.remove :effort
    end

    change_table :project_results, bulk: true do |t|
      t.integer :throughput_upstream, default: 0
      t.integer :throughput_downstream, default: 0
      t.remove :throughput
    end
  end

  def down
    change_table :demands, bulk: true do |t|
      t.remove :effort_downstream
      t.remove :effort_upstream

      t.decimal :effort, default: 0
    end

    change_table :project_results, bulk: true do |t|
      t.remove :throughput_upstream
      t.remove :throughput_downstream

      t.integer :throughput
    end
  end
end
