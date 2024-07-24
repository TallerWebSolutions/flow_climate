# frozen_string_literal: true

module Flow
  class TimeFlowInformation < SystemFlowInformation
    attr_reader :hours_delivered_upstream, :hours_delivered_downstream, :queue_time, :touch_time, :flow_efficiency,
                :average_queue_time, :average_touch_time

    def initialize(demands)
      super
      start_attributes_values
    end

    def hours_flow_behaviour(analysed_date)
      return if demands.blank?

      demands_finished_until_date = @demands.not_discarded_until(analysed_date).finished_until_date(analysed_date) # query

      build_hours_data_array(analysed_date)
      build_queue_touch_hash(demands_finished_until_date)
    end

    private

    def start_attributes_values
      @hours_delivered_upstream = []
      @hours_delivered_downstream = []
      @hours_per_demand = []
      @queue_time = []
      @touch_time = []
      @average_queue_time = []
      @average_touch_time = []
      @flow_efficiency = []
    end

    def build_queue_touch_hash(demands_finished_until_date)
      queue_time = demands_finished_until_date.sum(&:total_queue_time).to_f / 1.hour
      touch_time = demands_finished_until_date.sum(&:total_touch_time).to_f / 1.hour

      @queue_time << (queue_time - @queue_time.sum)
      @touch_time << (touch_time - @touch_time.sum)

      build_average_flow_times

      @flow_efficiency << Stats::StatisticsService.instance.compute_percentage(touch_time, queue_time)
    end

    def build_average_flow_times
      @average_queue_time << (@queue_time.compact.sum / @demands.kept.count)
      @average_touch_time << (@touch_time.compact.sum / @demands.kept.count)
    end

    def build_hours_data_array(analysed_date)
      demands_ids_to_efforts = @demands.map(&:id)
      demand_efforts_accumulated = DemandEffort.where(demand_id: demands_ids_to_efforts).until_date(analysed_date)

      hours_delivered_in_upstream = demand_efforts_accumulated.upstream_efforts.sum(&:effort_value).to_f
      hours_delivery_in_downstream = demand_efforts_accumulated.downstream_efforts.sum(&:effort_value).to_f

      @hours_delivered_upstream << (hours_delivered_in_upstream - @hours_delivered_upstream.sum)
      @hours_delivered_downstream << (hours_delivery_in_downstream - @hours_delivered_downstream.sum)
    end
  end
end
