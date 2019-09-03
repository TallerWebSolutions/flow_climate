# frozen_string_literal: true

module Highchart
  class TeamChartsAdapter < HighchartAdapter
    attr_reader :team, :average_demand_cost, :hours_efficiency

    def initialize(team, start_date, end_date, chart_period_interval)
      @team = team
      super(@team.projects, start_date, end_date, chart_period_interval)

      build_average_demand_cost
      build_hours_efficiency
    end

    private

    def build_average_demand_cost
      average_demand_cost_hash = TeamService.instance.compute_average_demand_cost_to_team(@team, @start_date, @end_date, @chart_period_interval)
      @average_demand_cost = { x_axis: average_demand_cost_hash.keys, data: average_demand_cost_hash.values }
    end

    def build_hours_efficiency
      hours_available_hash = TeamService.instance.compute_available_hours_to_team([@team], @start_date.to_date, @end_date.to_date, @chart_period_interval)
      hours_consumed_hash = TeamService.instance.compute_consumed_hours_to_team(@team, @start_date.to_date, @end_date.to_date, @chart_period_interval)

      @hours_efficiency = { x_axis: hours_available_hash.keys,
                            y_axis: [{ name: I18n.t('teams.charts.available_hours.data_legend'), data: hours_available_hash.values, type: 'column' },
                                     { name: I18n.t('teams.charts.hours_consumed.data_legend'), data: hours_consumed_hash.values, type: 'column' },
                                     { name: I18n.t('teams.charts.operational_loss.data_legend'),
                                       data: build_operational_loss(hours_available_hash.values, hours_consumed_hash.values),
                                       yAxis: 1,
                                       dashStyle: 'shortdot',
                                       tooltip: { valueSuffix: '%' },
                                       dataLabels: { enabled: true, format: '{point.y:.2f}%' } }] }
    end

    def build_operational_loss(hours_available_array, hours_consumed_array)
      operational_loss = []
      (0..(hours_available_array.size - 1)).each { |index| operational_loss << 100 - ((hours_consumed_array[index].to_f / hours_available_array[index]) * 100) }
      operational_loss
    end
  end
end
