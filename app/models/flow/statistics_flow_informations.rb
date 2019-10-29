# frozen_string_literal: true

module Flow
  class StatisticsFlowInformations < SystemFlowInformations
    attr_reader :average_aging_per_period, :lead_time_bins, :lead_time_histogram_data, :throughput_bins,
                :demands_charts_ids, :lead_time_data_array, :lead_time_accumulated,
                :lead_time_95p, :lead_time_80p, :lead_time_65p

    def initialize(demands)
      super(demands)

      start_attributes

      return if demands.blank?

      demands_with_lead_time = demands.finished_with_leadtime.order(:end_date) # query

      @demands_charts_ids = demands_with_lead_time.map(&:external_id)

      histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(demands_with_lead_time.map(&:leadtime_in_days).flatten)
      @lead_time_bins = histogram_data.keys.map { |leadtime| leadtime.round(2) }
      @lead_time_histogram_data = histogram_data.values

      build_lead_time_data(demands_with_lead_time)
      build_demands_external_ids_arrays(demands_with_lead_time)
    end

    def statistics_flow_behaviour(analysed_date)
      return if @demands.blank?

      demands_finished_with_lead_time_until_date = @demands.finished_with_leadtime.finished_until_date(analysed_date).order(:end_date) # query
      @lead_time_accumulated << Stats::StatisticsService.instance.percentile(80, demands_finished_with_lead_time_until_date.map(&:leadtime_in_days))
      @average_aging_per_period << if demands_finished_with_lead_time_until_date.count.positive?
                                     demands_finished_with_lead_time_until_date.map(&:aging_when_finished).sum.to_f / demands_finished_with_lead_time_until_date.count
                                   else
                                     0
                                   end
    end

    private

    def build_demands_external_ids_arrays(demands_with_lead_time)
      @demands_charts_ids = demands_with_lead_time.map(&:external_id)
    end

    def build_lead_time_data(demands_with_lead_time)
      @lead_time_data_array = demands_with_lead_time.map { |demand| demand.leadtime_in_days.to_f }
      @lead_time_95p = Stats::StatisticsService.instance.percentile(95, @lead_time_data_array)
      @lead_time_80p = Stats::StatisticsService.instance.percentile(80, @lead_time_data_array)
      @lead_time_65p = Stats::StatisticsService.instance.percentile(60, @lead_time_data_array)
    end

    def start_attributes
      @lead_time_data_array = []
      @lead_time_bins = []
      @average_aging_per_period = []
      @lead_time_accumulated = []
      @lead_time_histogram_data = []
      @demands_charts_ids = []

      @lead_time_95p = 0
      @lead_time_80p = 0
      @lead_time_65p = 0
    end
  end
end
