# frozen_string_literal: true

module Highchart
  class DemandsChartsAdapter
    attr_reader :x_axis, :demands_in_chart, :chart_period_interval, :throughput_chart_data, :creation_chart_data, :committed_chart_data,
                :leadtime_percentiles_on_time_chart_data, :demands_by_project, :pull_transaction_rate

    def initialize(demands, start_date, end_date, chart_period_interval)
      @chart_period_interval = chart_period_interval

      return if demands.blank?

      @start_date = beginning_of_period_for_query(start_date)
      @end_date = end_of_period_for_query(end_date)

      @x_axis = build_x_axis_for_date(@start_date, @end_date)

      @demands_in_chart = Demand.where(id: demands.map(&:id)).to_dates(@start_date, @end_date)

      build_creation_chart_data
      build_commitment_chart_data
      build_throughput_chart_data
      build_pull_transaction_rate

      build_leadtime_percentiles_on_time
      build_demands_by_project
    end

    private

    def build_creation_chart_data
      @creation_chart_data = []
      @x_axis.each do |date|
        @creation_chart_data << @demands_in_chart.where('demands.created_date BETWEEN :start_date AND :end_date', start_date: beginning_of_period_for_query(date), end_date: end_of_period_for_query(date)).count
      end
    end

    def build_commitment_chart_data
      @committed_chart_data = []
      @x_axis.each do |date|
        @committed_chart_data << @demands_in_chart.where('demands.commitment_date BETWEEN :start_date AND :end_date', start_date: beginning_of_period_for_query(date), end_date: end_of_period_for_query(date)).count
      end
    end

    def build_throughput_chart_data
      @throughput_chart_data = []
      @x_axis.each do |date|
        @throughput_chart_data << @demands_in_chart.where('demands.end_date BETWEEN :start_date AND :end_date', start_date: beginning_of_period_for_query(date), end_date: end_of_period_for_query(date)).count
      end
    end

    def build_pull_transaction_rate
      @pull_transaction_rate = []
      @x_axis.each do |date|
        @pull_transaction_rate << @demands_in_chart.joins(demand_transitions: :stage).where('stages.commitment_point = true AND demand_transitions.last_time_out BETWEEN :start_date AND :end_date', start_date: beginning_of_period_for_query(date), end_date: end_of_period_for_query(date)).count
      end
    end

    def build_leadtime_percentiles_on_time
      build_leadtime_on_time_data
    end

    def build_leadtime_on_time_data
      leadtime_data = []
      accumulated_leadtime_data = []
      @x_axis.each do |chart_date|
        start_date = beginning_of_period_for_query(chart_date)
        end_date = end_of_period_for_query(chart_date)

        demands_data = DemandsRepository.instance.demands_delivered_for_period(@demands_in_chart, start_date, end_date)
        leadtime_data << Stats::StatisticsService.instance.percentile(80, demands_data.map(&:leadtime_in_days))

        demands_data_accumulated = DemandsRepository.instance.demands_delivered_for_period_accumulated(@demands_in_chart, end_date)
        accumulated_leadtime_data << Stats::StatisticsService.instance.percentile(80, demands_data_accumulated.map(&:leadtime_in_days))
      end

      @leadtime_percentiles_on_time_chart_data = { y_axis: [{ name: I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence'), data: leadtime_data }, { name: I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence_accumulated'), data: accumulated_leadtime_data }] }
    end

    def build_demands_by_project
      demands_grouped = @demands_in_chart.joins(:project).group('projects.name').count.sort_by { |_key, value| value }.reverse.to_h

      @demands_by_project = { x_axis: demands_grouped.keys, y_axis: [{ name: I18n.t('general.demands'), data: demands_grouped.values, marker: { enabled: true } }] }
    end

    def beginning_of_period_for_query(date)
      return date.beginning_of_day if dayly?
      return date.beginning_of_week if weekly?
      return date.beginning_of_month if monthly

      date.beginning_of_year
    end

    def end_of_period_for_query(date)
      return date.end_of_day if dayly?
      return date.end_of_week if weekly?
      return date.end_of_month if monthly

      date.end_of_year
    end

    def build_x_axis_for_date(min_date, max_date)
      return TimeService.instance.days_between_of(min_date, max_date) if dayly?
      return TimeService.instance.weeks_between_of(min_date, max_date) if weekly?
      return TimeService.instance.months_between_of(min_date, max_date) if monthly

      TimeService.instance.years_between_of(min_date, max_date)
    end

    def dayly?
      @chart_period_interval == 'day'
    end

    def monthly
      @chart_period_interval == 'month'
    end

    def weekly?
      @chart_period_interval == 'week'
    end
  end
end
