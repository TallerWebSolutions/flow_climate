# frozen_string_literal: true

module Flow
  class TimeFlowInformations < SystemFlowInformations
    attr_reader :hours_delivered_upstream, :hours_delivered_downstream, :hours_per_demand, :queue_time, :touch_time, :flow_efficiency

    def initialize(dates_array, current_limit_date, demands)
      super(dates_array, current_limit_date, demands)

      @hours_delivered_upstream = []
      @hours_delivered_downstream = []
      @hours_per_demand = []
      @queue_time = []
      @touch_time = []
      @flow_efficiency = []

      hours_flow_behaviour
    end

    private

    def hours_flow_behaviour
      @dates_array.each do |date|
        next if @current_limit_date < date

        demands_finished_until_date = @demands.finished_until_date(date) # query

        build_hours_data_array(demands_finished_until_date)
        build_queue_touch_hash(demands_finished_until_date)
      end
    end

    def build_queue_touch_hash(demands_finished_until_date)
      queue_time = demands_finished_until_date.sum(&:total_queue_time).to_f / 1.hour
      touch_time = demands_finished_until_date.sum(&:total_touch_time).to_f / 1.hour

      @queue_time << queue_time - @queue_time.sum
      @touch_time << touch_time - @touch_time.sum
      @flow_efficiency << Stats::StatisticsService.instance.compute_percentage(touch_time, queue_time)
    end

    def build_hours_data_array(demands_delivered)
      hours_delivered_in_upstream = demands_delivered.sum(&:effort_upstream).to_f
      hours_delivery_in_downstream = demands_delivered.sum(&:effort_downstream).to_f

      @hours_delivered_upstream << hours_delivered_in_upstream - @hours_delivered_upstream.sum
      @hours_delivered_downstream << hours_delivery_in_downstream - @hours_delivered_downstream.sum

      @hours_per_demand << if demands_delivered.count.zero?
                             0
                           else
                             ((hours_delivered_in_upstream + hours_delivery_in_downstream) / demands_delivered.count).to_f
                           end
    end
  end
end
