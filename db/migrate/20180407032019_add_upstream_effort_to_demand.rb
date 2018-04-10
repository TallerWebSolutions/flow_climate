# frozen_string_literal: true

class AddUpstreamEffortToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :effort_downstream, :decimal, default: 0
    add_column :demands, :effort_upstream, :decimal, default: 0

    remove_column :demands, :effort, :decimal

    add_column :project_results, :throughput_upstream, :integer, default: 0
    add_column :project_results, :throughput_downstream, :integer, default: 0

    remove_column :project_results, :throughput, :integer
  end
end
