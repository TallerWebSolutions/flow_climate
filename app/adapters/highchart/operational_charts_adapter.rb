# frozen_string_literal: true

module Highchart
  class OperationalChartsAdapter < HighchartAdapter
    attr_reader :flow_pressure_data, :leadtime_bins, :lead_time_histogram_data,
                :queue_touch_share_hash, :average_demand_cost, :work_item_flow_information, :time_flow_information,
                :statistics_flow_information, :block_flow_information

    def initialize(demands, start_date, end_date, chart_period_interval)
      super(demands, start_date, end_date, chart_period_interval)

      @flow_pressure_data = []

      build_demand_data_processors
    end

    def scope_uncertainty
      [{ name: I18n.t('charts.scope.uncertainty'), y: uncertain_scope }, { name: I18n.t('charts.scope.created'), y: demands_list.count }].compact
    end

    private

    def build_demand_data_processors
      @work_item_flow_information = Flow::WorkItemFlowInformations.new(demands_list, uncertain_scope, @x_axis.length, @x_axis.last)
      @statistics_flow_information = Flow::StatisticsFlowInformations.new(demands_list)
      @time_flow_information = Flow::TimeFlowInformations.new(demands_list)
      @block_flow_information = Flow::BlockFlowInformations.new(demands_list)

      @x_axis.each_with_index(&method(:build_data_objects))
    end

    def build_data_objects(analysed_date, distribution_index)
      @work_item_flow_information.work_items_flow_behaviour(@start_date, analysed_date, distribution_index, add_data_to_chart?(analysed_date))
      @work_item_flow_information.build_cfd_hash(@start_date, analysed_date) if add_data_to_chart?(analysed_date)
      @statistics_flow_information.statistics_flow_behaviour(analysed_date) if add_data_to_chart?(analysed_date)
      @time_flow_information.hours_flow_behaviour(analysed_date) if add_data_to_chart?(analysed_date)
      @block_flow_information.blocks_flow_behaviour(analysed_date) if add_data_to_chart?(analysed_date)
    end
  end
end
