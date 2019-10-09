# frozen_string_literal: true

module Highchart
  class OperationalChartsAdapter < HighchartAdapter
    attr_reader :demands_burnup_data, :flow_pressure_data, :leadtime_bins, :lead_time_histogram_data, :throughput_bins,
                :throughput_histogram_data, :lead_time_control_chart, :leadtime_percentiles_on_time, :queue_touch_count_hash,
                :queue_touch_share_hash, :average_demand_cost, :work_item_flow_information, :time_flow_informations,
                :statistics_flow_information, :block_flow_information

    def initialize(projects, start_date, end_date, chart_period_interval)
      super(projects, start_date, end_date, chart_period_interval)

      @flow_pressure_data = []

      build_demand_data_processors
    end

    def scope_uncertainty
      [{ name: I18n.t('charts.scope.uncertainty'), y: uncertain_scope }, { name: I18n.t('charts.scope.created'), y: demands_list.count }].compact
    end

    private

    def build_demand_data_processors
      @work_item_flow_information = Flow::WorkItemFlowInformations.new(@x_axis, end_of_period_for_now, demands_list, uncertain_scope)
      @time_flow_informations = Flow::TimeFlowInformations.new(@x_axis, end_of_period_for_now, demands_list)
      @statistics_flow_information = Flow::StatisticsFlowInformations.new(@x_axis, end_of_period_for_now, demands_list)
      @block_flow_information = Flow::BlockFlowInformations.new(@x_axis, end_of_period_for_now, demands_list)
    end

    def end_of_period_for_now
      end_of_period_for_date(Time.zone.now)
    end
  end
end
