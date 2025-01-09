# frozen_string_literal: true

class DemandsListController < ApplicationController
  private

  def assign_consolidations
    if @demands.present?
      @confidence_95_leadtime = Stats::StatisticsService.instance.percentile(95, @demands.finished_with_leadtime.map(&:leadtime_in_days))
      @confidence_80_leadtime = Stats::StatisticsService.instance.percentile(80, @demands.finished_with_leadtime.map(&:leadtime_in_days))
      @confidence_65_leadtime = Stats::StatisticsService.instance.percentile(65, @demands.finished_with_leadtime.map(&:leadtime_in_days))
      build_flow_informations
    else
      @confidence_95_leadtime = 0
      @confidence_80_leadtime = 0
      @confidence_65_leadtime = 0
      @total_queue_time = 0
      @total_touch_time = 0
      @average_queue_time = 0
      @average_touch_time = 0
      @avg_work_hours_per_demand = 0
    end
  end

  def build_flow_informations
    @total_queue_time = @demands.sum(&:total_queue_time).to_f / 1.hour
    @total_touch_time = @demands.sum(&:total_touch_time).to_f / 1.hour
    @average_queue_time = @total_queue_time / @demands.count
    @average_touch_time = @total_touch_time / @demands.count
    @avg_work_hours_per_demand = @demands.with_effort.sum(&:total_effort) / @demands.count
  end
end
