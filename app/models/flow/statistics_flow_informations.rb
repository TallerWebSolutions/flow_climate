# frozen_string_literal: true

module Flow
  class StatisticsFlowInformations < SystemFlowInformations
    attr_reader :average_aging_per_period, :lead_time_bins, :lead_time_histogram_data, :throughput_bins,
                :demands_charts_ids, :lead_time_data_array, :lead_time_95p, :lead_time_80p, :lead_time_65p

    def initialize(dates_array, current_limit_date, demands)
      super(dates_array, current_limit_date, demands)

      @average_aging_per_period = []

      demands_with_lead_time = demands.finished_with_leadtime.order(:end_date)

      @demands_charts_ids = demands_with_lead_time.map(&:demand_id)

      histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(demands_with_lead_time.map(&:leadtime_in_days).flatten)
      @lead_time_bins = histogram_data.keys.map { |leadtime| leadtime.round(2) }
      @lead_time_histogram_data = histogram_data.values

      statistics_flow_behaviour
      build_lead_time_data(demands_with_lead_time)
    end

    private

    def statistics_flow_behaviour
      @dates_array.each do |date|
        next if @current_limit_date < date

        demands_finished_until_date = @demands.finished_until_date(date) # query
        @average_aging_per_period << demands_finished_until_date.map(&:aging_when_finished).sum.to_f / demands_finished_until_date.count
      end
    end

    def build_lead_time_data(demands_with_lead_time)
      @lead_time_data_array = demands_with_lead_time.map { |demand| demand.leadtime_in_days.to_f }
      @lead_time_95p = Stats::StatisticsService.instance.percentile(95, @lead_time_data_array)
      @lead_time_80p = Stats::StatisticsService.instance.percentile(80, @lead_time_data_array)
      @lead_time_65p = Stats::StatisticsService.instance.percentile(60, @lead_time_data_array)
    end
  end
end
