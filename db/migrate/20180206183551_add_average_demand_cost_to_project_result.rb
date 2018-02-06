# frozen_string_literal: true

class AddAverageDemandCostToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :cost_in_week, :decimal
    add_column :project_results, :average_demand_cost, :decimal

    team = Team.find_by(name: 'Vingadores')

    ProjectResult.all.each do |result|
      result.update(team: team) if result.team.blank?
      throughput = result.throughput
      throughput = 1 if throughput.zero?

      result.update(cost_in_week: result.team.total_cost, average_demand_cost: result.team.total_cost / throughput)
    end

    change_column_null :project_results, :cost_in_week, false
    change_column_null :project_results, :average_demand_cost, false
  end
end
