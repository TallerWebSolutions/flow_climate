# frozen_string_literal: true

class ScatterData
  attr_reader :completion_times, :items_ids, :completion_time_p95, :completion_time_p80, :completion_time_p65

  def initialize(completion_times, items_ids)
    @completion_times = completion_times
    @items_ids = items_ids

    @completion_time_p95 = Stats::StatisticsService.instance.percentile(95, @completion_times)
    @completion_time_p80 = Stats::StatisticsService.instance.percentile(80, @completion_times)
    @completion_time_p65 = Stats::StatisticsService.instance.percentile(65, @completion_times)
  end
end
