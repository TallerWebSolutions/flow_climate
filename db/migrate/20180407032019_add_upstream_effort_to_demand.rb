# frozen_string_literal: true

class AddUpstreamEffortToDemand < ActiveRecord::Migration[5.1]
  def change
    add_column :demands, :effort_downstream, :decimal, default: 0
    add_column :demands, :effort_upstream, :decimal, default: 0

    Demand.all.each { |demand| demand.update(effort_downstream: demand.effort) }

    remove_column :demands, :effort, :decimal

    add_column :project_results, :throughput_upstream, :integer, default: 0
    add_column :project_results, :throughput_downstream, :integer, default: 0

    ProjectResult.all.each { |result| result.update(throughput_downstream: result.throughput) }

    remove_column :project_results, :throughput, :integer
  end
end
