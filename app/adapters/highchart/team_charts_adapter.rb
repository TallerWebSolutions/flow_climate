# frozen_string_literal: true

module Highchart
  class TeamChartsAdapter < HighchartAdapter
    attr_reader :team, :average_demand_cost

    def initialize(team, start_date, end_date, chart_period_interval)
      @team = team
      super(@team.projects, start_date, end_date, chart_period_interval)

      build_average_demand_cost
    end

    private

    def build_average_demand_cost
      average_demand_cost_hash = TeamService.instance.compute_average_demand_cost_to_team(@team, @start_date, @end_date, @chart_period_interval)
      @average_demand_cost = { x_axis: average_demand_cost_hash.keys, data: average_demand_cost_hash.values }
    end
  end
end
