# frozen_string_literal: true

module Highchart
  class OperationalChartsAdapter < HighchartAdapter
    attr_reader :demands_burnup_data, :hours_burnup_per_week_data, :flow_pressure_data,
                :leadtime_bins, :leadtime_histogram_data, :throughput_bins, :throughput_histogram_data,
                :lead_time_control_chart, :leadtime_percentiles_on_time, :weeekly_bugs_count_hash, :weeekly_bugs_share_hash, :weekly_queue_touch_count_hash,
                :weekly_queue_touch_share_hash

    def initialize(projects, start_date, end_date, chart_period_interval)
      super(projects, start_date, end_date, chart_period_interval)

      @flow_pressure_data = []

      @demands_burnup_data = Highchart::BurnupChartsAdapter.new(@x_axis, build_demands_scope_data, build_demands_throughput_data)
      @hours_burnup_per_week_data = Highchart::BurnupChartsAdapter.new(@x_axis, build_hours_scope_data, build_hours_throughput_data)

      build_weeekly_bugs_count_hash
      build_weeekly_bugs_share_hash
      build_weekly_queue_touch_count_hash
      build_weekly_queue_touch_share_hash

      build_flow_pressure_array
      build_statistics_charts
    end

    def hours_per_demand
      chart_data = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        chart_data << compute_hours_per_demand_to_date(date)
      end

      chart_data
    end

    def throughput_per_period
      upstream_result_data = []
      downstream_result_data = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        upstream_result_data << DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'upstream', date).count
        downstream_result_data << DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'downstream', date).count
      end

      [{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: downstream_result_data }]
    end

    def effort_hours_per_month
      grouped_hours_to_upstream = DemandsRepository.instance.effort_upstream_grouped_by_month(all_projects, @start_date)
      grouped_hours_to_downstream = DemandsRepository.instance.grouped_by_effort_downstream_per_month(all_projects, @start_date)

      hours_per_month_data_hash = {}

      hours_per_month_data_hash[:keys] = group_all_keys(grouped_hours_to_downstream, grouped_hours_to_upstream)

      data_upstream = []
      data_downstream = []

      hours_per_month_data_hash[:keys].each do |month|
        data_upstream << grouped_hours_to_upstream[month]&.to_f || 0
        data_downstream << grouped_hours_to_downstream[month]&.to_f || 0
      end

      hours_per_month_data_hash[:data] = { upstream: data_upstream, downstream: data_downstream }
      hours_per_month_data_hash
    end

    private

    def compute_hours_per_demand_to_date(date)
      demands_finished_upstream = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'upstream', date)
      demands_finished_downstream = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'downstream', date)

      effort_upstream = demands_finished_upstream.sum(&:effort_upstream) + demands_finished_downstream.sum(&:effort_upstream)
      effort_downstream = demands_finished_downstream.sum(&:effort_downstream)

      total_throughput = demands_finished_upstream.count + demands_finished_downstream.count

      ((effort_upstream + effort_downstream) / total_throughput.to_f).to_f
    end

    def group_all_keys(grouped_hours_to_downstream, grouped_hours_to_upstream)
      grouped_hours_to_upstream.keys | grouped_hours_to_downstream.keys
    end

    def build_statistics_charts
      build_lead_time_control_chart
      build_leadtime_histogram
      build_throughput_histogram
    end

    def build_flow_pressure_array
      array_of_flow_pressures = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        @all_projects.each { |project| array_of_flow_pressures << project.flow_pressure(date.end_of_day.end_of_week) }
        @flow_pressure_data << array_of_flow_pressures.sum.to_f / array_of_flow_pressures.count.to_f
      end
    end

    def add_data_to_chart?(date)
      limit_date = if @chart_period_interval == 'day'
                     Time.zone.today.end_of_day
                   elsif @chart_period_interval == 'week'
                     Time.zone.today.end_of_week
                   else
                     Time.zone.today.end_of_month
                   end

      date <= limit_date
    end

    def build_demands_scope_data
      scope_per_week = []
      @x_axis.each { |date| scope_per_week << DemandsRepository.instance.known_scope_to_date(all_projects, date.beginning_of_day) }
      scope_per_week
    end

    def build_demands_throughput_data
      throughput_per_period = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        upstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'upstream', date).count
        downstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'downstream', date).count
        throughput_per_period << upstream_total_delivered + downstream_total_delivered
      end
      throughput_per_period
    end

    def build_hours_scope_data
      scope_per_week = []
      @x_axis.each { |_week_year| scope_per_week << @all_projects.sum(:qty_hours).to_f }
      scope_per_week
    end

    def build_hours_throughput_data
      throughput_hours_per_period = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        upstream_total_hours_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'upstream', date).sum(&:effort_upstream)
        downstream_total_hours_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'downstream', date).sum(&:effort_downstream)

        throughput_hours_per_period << upstream_total_hours_delivered + downstream_total_hours_delivered
      end
      throughput_hours_per_period
    end

    def build_lead_time_control_chart
      @lead_time_control_chart = {}
      @lead_time_control_chart[:xcategories] = finished_demands_with_leadtime.map(&:demand_id)
      @lead_time_control_chart[:dispersion_source] = finished_demands_with_leadtime.map { |demand| [demand.demand_id, demand.leadtime_in_days.to_f] }
      @lead_time_control_chart[:percentile_95_data] = Stats::StatisticsService.instance.percentile(95, demand_data)
      @lead_time_control_chart[:percentile_80_data] = Stats::StatisticsService.instance.percentile(80, demand_data)
      @lead_time_control_chart[:percentile_60_data] = Stats::StatisticsService.instance.percentile(60, demand_data)
    end

    def build_weeekly_bugs_count_hash
      dates_array = []
      bugs_opened_count_array = []
      bugs_closed_count_array = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        dates_array << date.to_s
        bugs_opened_count_array << DemandsRepository.instance.bugs_opened_until_limit_date(@all_projects, date)
        bugs_closed_count_array << DemandsRepository.instance.bugs_closed_until_limit_date(@all_projects, date)
      end
      @weeekly_bugs_count_hash = { dates_array: dates_array, bugs_opened_count_array: bugs_opened_count_array, bugs_closed_count_array: bugs_closed_count_array }
    end

    def build_weeekly_bugs_share_hash
      dates_array = []
      bugs_opened_share_array = []
      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        dates_array << date.to_s
        scope_in_week = DemandsRepository.instance.known_scope_to_date(@all_projects, date.beginning_of_day)
        bugs_in_week = DemandsRepository.instance.bugs_opened_until_limit_date(@all_projects, date)
        bugs_opened_share_array << Stats::StatisticsService.instance.compute_percentage(bugs_in_week, scope_in_week)
      end
      @weeekly_bugs_share_hash = { dates_array: dates_array, bugs_opened_share_array: bugs_opened_share_array }
    end

    def build_weekly_queue_touch_count_hash
      dates_array = []
      queue_times = []
      touch_times = []
      queue_times_per_week_hash = DemandsRepository.instance.total_time_for(@all_projects, 'total_queue_time')
      touch_times_per_week_hash = DemandsRepository.instance.total_time_for(@all_projects, 'total_touch_time')

      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        demands_touch_block_total_time = compute_demands_touch_block_total_time(date)
        dates_array << date.to_s
        queue_times << compute_time_in_seconds_to_hours(date, queue_times_per_week_hash, demands_touch_block_total_time)
        touch_times << compute_time_in_seconds_to_hours(date, touch_times_per_week_hash, (demands_touch_block_total_time * -1))
      end
      @weekly_queue_touch_count_hash = { dates_array: dates_array, queue_times: queue_times, touch_times: touch_times }
    end

    def compute_demands_touch_block_total_time(date)
      @all_projects.map { |project| project.demands.kept.where('EXTRACT(WEEK FROM end_date) = :week AND EXTRACT(YEAR FROM end_date) = :year', week: date.cweek, year: date.cwyear).sum(&:sum_touch_blocked_time) }.sum
    end

    def compute_time_in_seconds_to_hours(date, times_per_week_hash, blocking_time)
      ((times_per_week_hash[[date.cweek, date.cwyear]] || 0) + blocking_time) / (60 * 60)
    end

    def build_weekly_queue_touch_share_hash
      dates_array = []
      flow_efficiency_array = []

      queue_times_per_week_hash = DemandsRepository.instance.total_time_for(@all_projects, 'total_queue_time')
      touch_times_per_week_hash = DemandsRepository.instance.total_time_for(@all_projects, 'total_touch_time')

      @x_axis.each do |date|
        break unless add_data_to_chart?(date)

        dates_array << date.to_s
        flow_efficiency_array << compute_flow_efficiency(date, queue_times_per_week_hash, touch_times_per_week_hash)
      end
      @weekly_queue_touch_share_hash = { dates_array: dates_array, flow_efficiency_array: flow_efficiency_array }
    end

    def compute_flow_efficiency(date, queue_times_per_week_hash, touch_times_per_week_hash)
      queue_time = (queue_times_per_week_hash[[date.cweek, date.cwyear]] || 0)
      touch_time = (touch_times_per_week_hash[[date.cweek, date.cwyear]] || 0)
      Stats::StatisticsService.instance.compute_percentage(touch_time, queue_time)
    end

    def build_leadtime_histogram
      histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(finished_demands_with_leadtime.map(&:leadtime_in_days).flatten)
      @leadtime_bins = histogram_data.keys.map { |leadtime| "#{leadtime.round(2)} #{I18n.t('projects.charts.xlabel.days')}" }
      @leadtime_histogram_data = histogram_data.values
    end

    def build_throughput_histogram
      histogram_data = Stats::StatisticsService.instance.throughput_histogram_hash(ProjectsRepository.instance.throughput_per_week(@all_projects, @start_date).values)
      @throughput_bins = histogram_data.keys.map { |th| "#{th.round(2)} #{I18n.t('charts.demand.title')}" }
      @throughput_histogram_data = histogram_data.values
    end

    def demand_data
      @demand_data ||= finished_demands_with_leadtime.map { |demand| demand.leadtime_in_days.to_f }
    end

    def finished_demands_with_leadtime
      @finished_demands_with_leadtime ||= Demand.kept.where(project_id: @all_projects.map(&:id)).finished_with_leadtime_after_date(@start_date).order(:end_date)
    end
  end
end
