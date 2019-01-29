# frozen_string_literal: true

module Highchart
  class DemandsChartsAdapter
    attr_reader :demands_in_chart, :grouped_period, :throughput_chart_data, :creation_chart_data, :committed_chart_data

    def initialize(demands, grouped_period)
      @demands_in_chart = demands
      @grouped_period = grouped_period

      build_creation_chart_data
      build_commitment_chart_data
      build_throughput_chart_data
    end

    private

    def build_creation_chart_data
      creation_rate_data = DemandsRepository.instance.count_grouped_per_period(@demands_in_chart, :created_date, @grouped_period)
      min_date = [@demands_in_chart.minimum(:created_date), Time.zone.now].compact.min.to_date
      max_date = [@demands_in_chart.maximum(:created_date), Time.zone.now].compact.min.to_date

      @creation_chart_data = { x_axis: build_x_axis_for_date(min_date, max_date), y_axis: [{ name: I18n.t('demands.charts.creation_date'), data: creation_rate_data.values }] }
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

    def build_x_axis_for_date(min_date, max_date)
      return TimeService.instance.days_between_of(min_date, max_date) if grouped_period == 'day'
      return TimeService.instance.weeks_between_of(min_date, max_date) if grouped_period == 'week'
      return TimeService.instance.months_between_of(min_date, max_date) if grouped_period == 'month'

      TimeService.instance.months_between_of(min_date, max_date)
    end
  end
end
