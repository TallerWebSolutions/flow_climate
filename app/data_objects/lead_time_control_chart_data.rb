# frozen_string_literal: true

class LeadTimeControlChartData
  attr_reader :x_axis, :lead_times, :lead_time_p65, :lead_time_p80, :lead_time_p95

  def initialize(demands_finished)
    ordered_finished = demands_finished.finished_with_leadtime.order(:end_date)

    @x_axis = ordered_finished.map(&:external_id)
    lead_times_array = ordered_finished.map(&:leadtime)

    @lead_times = lead_times_array
    @lead_time_p65 = Stats::StatisticsService.instance.percentile(65, lead_times_array)
    @lead_time_p80 = Stats::StatisticsService.instance.percentile(80, lead_times_array)
    @lead_time_p95 = Stats::StatisticsService.instance.percentile(95, lead_times_array)
  end
end
