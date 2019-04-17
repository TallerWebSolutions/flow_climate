# frozen_string_literal: true

module Highchart
  class DemandsChartsAdapter
    attr_reader :demands_in_chart, :grouped_period, :throughput_chart_data, :creation_chart_data, :committed_chart_data, :leadtime_percentiles_on_time_chart_data

    def initialize(demands, start_date, end_date, grouped_period)
      @grouped_period = grouped_period

      @start_date = beginning_of_period_for_query(start_date)
      @end_date = end_of_period_for_query(end_date)

      return if demands.blank?

      @demands_in_chart = demands.to_dates(@start_date, @end_date)

      build_creation_chart_data
      build_commitment_chart_data
      build_throughput_chart_data
      build_leadtime_percentiles_on_time
    end

    private

    def build_creation_chart_data
      created_demands_in_period = Demand.where('created_date BETWEEN :start_date AND :end_date', start_date: @start_date, end_date: @end_date)
      creation_rate_data = DemandsRepository.instance.count_grouped_per_period(created_demands_in_period, :created_date, @grouped_period)

      @creation_chart_data = { x_axis: build_x_axis_for_date(@start_date, @end_date), y_axis: [{ name: I18n.t('demands.charts.creation_date'), data: creation_rate_data.values }] }
    end

    def build_commitment_chart_data
      commitment_rate_data = DemandsRepository.instance.count_grouped_per_period(@demands_in_chart, :commitment_date, @grouped_period)
      min_date = [@demands_in_chart.minimum(:commitment_date), Time.zone.now].compact.min.to_date
      max_date = [@demands_in_chart.maximum(:commitment_date), Time.zone.now].compact.min.to_date

      @committed_chart_data = { x_axis: build_x_axis_for_date(min_date, max_date), y_axis: [{ name: I18n.t('demands.charts.commitment_date'), data: commitment_rate_data.values }] }
    end

    def build_throughput_chart_data
      throughput_data = DemandsRepository.instance.count_grouped_per_period(@demands_in_chart, :end_date, @grouped_period)
      min_date = [@demands_in_chart.minimum(:end_date), Time.zone.now].compact.min.to_date
      max_date = [@demands_in_chart.maximum(:end_date), Time.zone.now].compact.min.to_date

      @throughput_chart_data = { x_axis: build_x_axis_for_date(min_date, max_date), y_axis: [{ name: I18n.t('general.throughput'), data: throughput_data.values }] }
    end

    def build_leadtime_percentiles_on_time
      min_date = [@demands_in_chart.minimum(:end_date), Time.zone.now].compact.min.to_date
      max_date = [@demands_in_chart.maximum(:end_date), Time.zone.now].compact.min.to_date
      x_axis = build_x_axis_for_date(min_date, max_date)

      build_leadtime_on_time_data(x_axis)
    end

    def build_leadtime_on_time_data(x_axis)
      leadtime_data = []
      accumulated_leadtime_data = []
      x_axis.each do |chart_date|
        start_date = beginning_of_period_for_query(chart_date)
        end_date = end_of_period_for_query(chart_date)

        demands_data = DemandsRepository.instance.demands_delivered_for_period(@demands_in_chart, start_date, end_date)
        leadtime_data << Stats::StatisticsService.instance.percentile(80, demands_data.map(&:leadtime_in_days))

        demands_data_accumulated = DemandsRepository.instance.demands_delivered_for_period_accumulated(@demands_in_chart, end_date)
        accumulated_leadtime_data << Stats::StatisticsService.instance.percentile(80, demands_data_accumulated.map(&:leadtime_in_days))
      end

      @leadtime_percentiles_on_time_chart_data = { x_axis: x_axis, y_axis: [{ name: I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence'), data: leadtime_data }, { name: I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence_accumulated'), data: accumulated_leadtime_data }] }
    end

    def beginning_of_period_for_query(date)
      return date.beginning_of_day if @grouped_period == 'day'
      return date.beginning_of_week if @grouped_period == 'week'
      return date.beginning_of_month if @grouped_period == 'month'

      date.beginning_of_year
    end

    def end_of_period_for_query(date)
      return date.end_of_day if @grouped_period == 'day'
      return date.end_of_week if @grouped_period == 'week'
      return date.end_of_month if @grouped_period == 'month'

      date.end_of_year
    end

    def build_x_axis_for_date(min_date, max_date)
      return TimeService.instance.days_between_of(min_date, max_date) if @grouped_period == 'day'
      return TimeService.instance.weeks_between_of(min_date, max_date) if @grouped_period == 'week'
      return TimeService.instance.months_between_of(min_date, max_date) if @grouped_period == 'month'

      TimeService.instance.months_between_of(min_date, max_date)
    end
  end
end
