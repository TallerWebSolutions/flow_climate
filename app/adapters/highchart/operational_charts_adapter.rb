# frozen_string_literal: true

module Highchart
  class OperationalChartsAdapter < HighchartAdapter
    attr_reader :demands_burnup_data, :hours_burnup_per_week_data, :flow_pressure_data,
                :leadtime_bins, :leadtime_histogram_data, :throughput_bins, :throughput_histogram_data,
                :lead_time_control_chart, :leadtime_percentiles_on_time, :weeekly_bugs_count_hash, :weeekly_bugs_share_hash, :weekly_queue_touch_count_hash,
                :weekly_queue_touch_share_hash

    def initialize(projects, period)
      super(projects, period)
      @flow_pressure_data = []
      @demands_burnup_data = Highchart::BurnupChartsAdapter.new(@all_projects_weeks, build_demands_scope_data, build_demands_throughput_data)
      @hours_burnup_per_week_data = Highchart::BurnupChartsAdapter.new(@all_projects_weeks, build_hours_scope_data, build_hours_throughput_data)

      build_weeekly_bugs_count_hash
      build_weeekly_bugs_share_hash
      build_weekly_queue_touch_count_hash
      build_weekly_queue_touch_share_hash
      build_flow_pressure_array
      build_statistics_charts
    end

    def hours_per_demand_per_week
      chart_data = []
      @all_projects_weeks.each do |date|
        break unless add_data_to_chart?(date)

        chart_data << build_chart_data(date)
      end

      chart_data
    end

    def throughput_per_week
      throughput_chart_data
    end

    def effort_hours_per_month
      grouped_hours_to_upstream = DemandsRepository.instance.grouped_by_effort_upstream_per_month(all_projects, charts_data_bottom_limit_date)
      grouped_hours_to_downstream = DemandsRepository.instance.grouped_by_effort_downstream_per_month(all_projects, charts_data_bottom_limit_date)

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

    def build_chart_data(date)
      upstream_keys_matching = @upstream_operational_weekly_data.keys.select { |key| key == date }
      upstream_throughput = upstream_operational_data_for_week(upstream_keys_matching, :throughput)

      downstream_keys_matching = @downstream_operational_weekly_data.keys.select { |key| key == date }
      downstream_throughput = downstream_operational_data_for_week(downstream_keys_matching, :throughput)

      throughput_total = upstream_throughput + downstream_throughput

      if throughput_total.zero? || (upstream_keys_matching.blank? && downstream_keys_matching.blank?)
        0
      else
        compute_hour_per_demand(throughput_total, (upstream_keys_matching + downstream_keys_matching).uniq)
      end
    end

    def compute_hour_per_demand(throughput_total, upstream_keys_matching)
      hours_for_week_upstream_data = upstream_operational_data_for_week(upstream_keys_matching, :total_effort_upstream)
      hours_for_week_downstream_data = downstream_operational_data_for_week(upstream_keys_matching, :total_effort_upstream) + downstream_operational_data_for_week(upstream_keys_matching, :total_effort_downstream)

      hours_of_effort_total = hours_for_week_upstream_data + hours_for_week_downstream_data

      hours_of_effort_total.to_f / throughput_total.to_f
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
      @all_projects_weeks.each do |date|
        @all_projects.each { |project| array_of_flow_pressures << project.flow_pressure(date) }
        @flow_pressure_data << array_of_flow_pressures.sum.to_f / array_of_flow_pressures.count.to_f
      end
    end

    def build_demands_scope_data
      scope_per_week = []
      @all_projects_weeks.each { |date| scope_per_week << DemandsRepository.instance.scope_in_week_for_projects(all_projects, date.cweek, date.cwyear) }
      scope_per_week
    end

    def build_demands_throughput_data
      throughput_per_week = []
      @all_projects_weeks.each do |date|
        upstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_upstream(@all_projects, date).count
        downstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_downstream(@all_projects, date).count
        throughput_per_week << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(date)
      end
      throughput_per_week
    end

    def build_hours_scope_data
      scope_per_week = []
      @all_projects_weeks.each { |_week_year| scope_per_week << @all_projects.sum(:qty_hours).to_f }
      scope_per_week
    end

    def build_hours_throughput_data
      throughput_hours_per_week = []
      @all_projects_weeks.each do |date|
        upstream_total_hours_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_upstream(@all_projects, date).sum(&:effort_upstream)
        downstream_total_hours_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_downstream(@all_projects, date).sum(&:effort_downstream)

        throughput_hours_per_week << upstream_total_hours_delivered + downstream_total_hours_delivered if add_data_to_chart?(date)
      end
      throughput_hours_per_week
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
      @all_projects_weeks.each do |date|
        dates_array << date.to_s
        bugs_opened_count_array << DemandsRepository.instance.bugs_opened_until_week(@all_projects, date)
        bugs_closed_count_array << DemandsRepository.instance.bugs_closed_until_week(@all_projects, date)
      end
      @weeekly_bugs_count_hash = { dates_array: dates_array, bugs_opened_count_array: bugs_opened_count_array, bugs_closed_count_array: bugs_closed_count_array }
    end

    def build_weeekly_bugs_share_hash
      dates_array = []
      bugs_opened_share_array = []
      @all_projects_weeks.each do |date|
        dates_array << date.to_s
        scope_in_week = DemandsRepository.instance.scope_in_week_for_projects(@all_projects, date.cweek, date.cwyear)
        bugs_in_week = DemandsRepository.instance.bugs_opened_until_week(@all_projects, date)
        bugs_opened_share_array << Stats::StatisticsService.instance.compute_percentage(bugs_in_week, scope_in_week)
      end
      @weeekly_bugs_share_hash = { dates_array: dates_array, bugs_opened_share_array: bugs_opened_share_array }
    end

    def build_weekly_queue_touch_count_hash
      dates_array = []
      queue_times = []
      touch_times = []
      queue_times_per_week_hash = ProjectsRepository.instance.total_queue_time_for(@all_projects)
      touch_times_per_week_hash = ProjectsRepository.instance.total_touch_time_for(@all_projects)

      @all_projects_weeks.each do |date|
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
      queue_times_per_week_hash = ProjectsRepository.instance.total_queue_time_for(@all_projects)
      touch_times_per_week_hash = ProjectsRepository.instance.total_touch_time_for(@all_projects)

      @all_projects_weeks.each do |date|
        dates_array << date.to_s

        queue_time = (queue_times_per_week_hash[[date.cweek, date.cwyear]] || 0)
        touch_time = (touch_times_per_week_hash[[date.cweek, date.cwyear]] || 0)
        flow_efficiency_array << Stats::StatisticsService.instance.compute_percentage(touch_time, queue_time)
      end
      @weekly_queue_touch_share_hash = { dates_array: dates_array, flow_efficiency_array: flow_efficiency_array }
    end

    def build_leadtime_histogram
      histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(finished_demands_with_leadtime.map(&:leadtime_in_days).flatten)
      @leadtime_bins = histogram_data.keys.map { |leadtime| "#{leadtime.round(2)} #{I18n.t('projects.charts.xlabel.days')}" }
      @leadtime_histogram_data = histogram_data.values
    end

    def build_throughput_histogram
      histogram_data = Stats::StatisticsService.instance.throughput_histogram_hash(ProjectsRepository.instance.throughput_per_week(@all_projects, charts_data_bottom_limit_date).values)
      @throughput_bins = histogram_data.keys.map { |th| "#{th.round(2)} #{I18n.t('charts.demand.title')}" }
      @throughput_histogram_data = histogram_data.values
    end

    def demand_data
      @demand_data ||= finished_demands_with_leadtime.map { |demand| demand.leadtime_in_days.to_f }
    end

    def finished_demands_with_leadtime
      @finished_demands_with_leadtime ||= Demand.kept.where(project_id: @all_projects.map(&:id)).finished_with_leadtime_after_date(charts_data_bottom_limit_date).order(:end_date)
    end
  end
end
