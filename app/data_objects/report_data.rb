# frozen_string_literal: true

class ReportData < ChartData
  attr_reader :demands_burnup_data, :hours_burnup_data, :flow_pressure_data, :monte_carlo_data,
              :leadtime_bins, :leadtime_histogram_data, :throughput_bins, :throughput_histogram_data,
              :lead_time_control_chart, :weeekly_bugs_count_hash, :weeekly_bugs_share_hash, :weeekly_queue_touch_count_hash,
              :weeekly_queue_touch_share_hash

  def initialize(projects)
    super(projects)
    @flow_pressure_data = []
    @demands_burnup_data = BurnupData.new(@active_weeks, build_demands_scope_data, build_demands_throughput_data)
    @hours_burnup_data = BurnupData.new(@all_projects_weeks, build_hours_scope_data, build_hours_throughput_data)

    build_weeekly_bugs_count_hash
    build_weeekly_bugs_share_hash
    build_weeekly_queue_touch_count_hash
    build_weeekly_queue_touch_share_hash
    build_flow_pressure_array
    build_statistics_charts
  end

  def hours_per_demand_per_week
    weekly_data = ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects(all_projects)

    result_data = []
    @all_projects_weeks.each do |week_year|
      break unless add_data_to_chart?(week_year)
      keys_matching = weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      result_data << (weekly_data[keys_matching.first] || 0)
    end
    result_data
  end

  def throughput_per_week
    upstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(all_projects, :upstream)
    downstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(all_projects, :downstream)

    throughput_chart_data(downstream_th_weekly_data, upstream_th_weekly_data)
  end

  def average_demand_cost
    weekly_data = ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects(all_projects)

    result_data = []
    @all_projects_weeks.each do |week_year|
      break unless add_data_to_chart?(week_year)
      keys_matching = weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      result_data << (weekly_data[keys_matching.first] || 0)
    end
    result_data
  end

  def effort_hours_per_month
    grouped_hours_to_upstream = DemandsRepository.instance.grouped_by_effort_upstream_per_month(all_projects)
    grouped_hours_to_downstream = DemandsRepository.instance.grouped_by_effort_downstream_per_month(all_projects)

    hours_per_month_data_hash = {}

    hours_per_month_data_hash[:keys] = grouped_hours_to_upstream.keys | grouped_hours_to_downstream.keys

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

  def build_statistics_charts
    build_lead_time_control_chart
    build_leadtime_histogram
    build_throughput_histogram
  end

  def throughput_chart_data(downstream_th_weekly_data, upstream_th_weekly_data)
    upstream_result_data = []
    downstream_result_data = []
    @all_projects_weeks.each do |week_year|
      break unless add_data_to_chart?(week_year)
      upstream_keys_matching = upstream_th_weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      upstream_result_data << (upstream_th_weekly_data[upstream_keys_matching.first] || 0)

      downstream_keys_matching = downstream_th_weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      downstream_result_data << (downstream_th_weekly_data[downstream_keys_matching.first] || 0)
    end
    [{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: downstream_result_data }]
  end

  def build_flow_pressure_array
    weekly_data = ProjectResultsRepository.instance.flow_pressure_in_week_for_projects(all_projects)

    @all_projects_weeks.each do |week_year|
      begining_of_week = Date.commercial(week_year[1], week_year[0], 1)
      keys_matching = weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      add_actual_or_projected_data(begining_of_week, keys_matching, weekly_data)
    end
  end

  def date_hash_matches?(key, week_year)
    key.to_date.cweek == week_year[0] && key.to_date.cwyear == week_year[1]
  end

  def add_actual_or_projected_data(begining_of_week, keys_matching, weekly_data)
    @flow_pressure_data << (weekly_data[keys_matching.first].to_f || 0.0) if keys_matching.present? || begining_of_week <= Time.zone.today
    @flow_pressure_data << all_projects.sum { |p| p.flow_pressure(begining_of_week) } / all_projects.count.to_f if begining_of_week.future?
  end

  def build_demands_scope_data
    scope_per_week = []
    @active_weeks.each do |week_year|
      scope_per_week << ProjectResultsRepository.instance.scope_in_week_for_projects(active_projects, week_year[0], week_year[1])
    end
    scope_per_week
  end

  def build_demands_throughput_data
    throughput_per_week = []
    @active_weeks.each do |week_year|
      week = week_year[0]
      year = week_year[1]
      upstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, active_projects, :throughput_upstream)
      downstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, active_projects, :throughput_downstream)
      throughput_per_week << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(week_year)
    end
    throughput_per_week
  end

  def build_hours_scope_data
    scope_per_week = []
    @all_projects_weeks.each { |_week_year| scope_per_week << @all_projects.sum(:qty_hours).to_f }
    scope_per_week
  end

  def build_hours_throughput_data
    throughput_per_week = []
    @all_projects_weeks.each do |week_year|
      week = week_year[0]
      year = week_year[1]
      upstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, all_projects, :qty_hours_upstream)
      downstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, all_projects, :qty_hours_downstream)
      throughput_per_week << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(week_year)
    end
    throughput_per_week
  end

  def delivered_to_projects_and_stream_until_week(week, year, projects, metric_field)
    ProjectResult.until_week(week, year).where(project_id: projects.map(&:id)).sum(metric_field)
  end

  def build_lead_time_control_chart
    @lead_time_control_chart = {}
    @lead_time_control_chart[:xcategories] = finished_demands.map(&:demand_id)
    @lead_time_control_chart[:dispersion_source] = finished_demands.map { |demand| [demand.demand_id, (demand.leadtime / 86_400).to_f] }
    @lead_time_control_chart[:percentile_95_data] = Stats::StatisticsService.instance.percentile(95, demand_data)
    @lead_time_control_chart[:percentile_80_data] = Stats::StatisticsService.instance.percentile(80, demand_data)
    @lead_time_control_chart[:percentile_60_data] = Stats::StatisticsService.instance.percentile(60, demand_data)
  end

  def build_weeekly_bugs_count_hash
    dates_array = []
    bugs_opened_count_array = []
    bugs_closed_count_array = []
    @all_projects_weeks.each do |week_year|
      date = Date.commercial(week_year[1], week_year[0], 1)
      dates_array << date.to_s
      bugs_opened_count_array << ProjectResultsRepository.instance.bugs_opened_in_week(@all_projects, date)
      bugs_closed_count_array << ProjectResultsRepository.instance.bugs_closed_in_week(@all_projects, date)
    end
    @weeekly_bugs_count_hash = { dates_array: dates_array, bugs_opened_count_array: bugs_opened_count_array, bugs_closed_count_array: bugs_closed_count_array }
  end

  def build_weeekly_bugs_share_hash
    dates_array = []
    bugs_opened_share_array = []
    @all_projects_weeks.each do |week_year|
      date = Date.commercial(week_year[1], week_year[0], 1)
      dates_array << date.to_s
      scope_in_week = ProjectResultsRepository.instance.scope_in_week_for_projects(@all_projects, week_year[0], week_year[1])
      bugs_in_week = ProjectResultsRepository.instance.bugs_opened_until_week(@all_projects, date)
      bugs_opened_share_array << compute_percentage(bugs_in_week, scope_in_week)
    end
    @weeekly_bugs_share_hash = { dates_array: dates_array, bugs_opened_share_array: bugs_opened_share_array }
  end

  def build_weeekly_queue_touch_count_hash
    dates_array = []
    queue_times = []
    touch_times = []
    @all_projects_weeks.each do |week_year|
      date = Date.commercial(week_year[1], week_year[0], 1)
      dates_array << date.to_s
      queue_times << ProjectsRepository.instance.total_queue_time_for(@all_projects, date)
      touch_times << ProjectsRepository.instance.total_touch_time_for(@all_projects, date)
    end
    @weeekly_queue_touch_count_hash = { dates_array: dates_array, queue_times: queue_times, touch_times: touch_times }
  end

  def build_weeekly_queue_touch_share_hash
    dates_array = []
    flow_efficiency_array = []
    @all_projects_weeks.each do |week_year|
      date = Date.commercial(week_year[1], week_year[0], 1)
      dates_array << date.to_s

      queue_time = ProjectsRepository.instance.total_queue_time_for(@all_projects, date)
      touch_time = ProjectsRepository.instance.total_touch_time_for(@all_projects, date)
      flow_efficiency_array << compute_percentage(touch_time, queue_time)
    end
    @weeekly_queue_touch_share_hash = { dates_array: dates_array, flow_efficiency_array: flow_efficiency_array }
  end

  def compute_percentage(data_count_analysed, data_count_remaining)
    return 0 if data_count_remaining.zero?
    (data_count_analysed.to_f / (data_count_analysed.to_f + data_count_remaining.to_f) * 100)
  end

  def build_leadtime_histogram
    histogram_data = Stats::StatisticsService.instance.leadtime_histogram_hash(finished_demands.map(&:leadtime).flatten)
    @leadtime_bins = histogram_data.keys.map { |leadtime| "#{(leadtime / 86_400).round(2)} #{I18n.t('projects.charts.xlabel.days')}" }
    @leadtime_histogram_data = histogram_data.values
  end

  def build_throughput_histogram
    histogram_data = Stats::StatisticsService.instance.throughput_histogram_hash(ProjectsRepository.instance.throughput_per_week(all_projects).values)
    @throughput_bins = histogram_data.keys.map { |th| "#{th} #{I18n.t('charts.demand.title')}" }
    @throughput_histogram_data = histogram_data.values
  end

  def demand_data
    @demand_data ||= finished_demands.map { |demand| (demand.leadtime / 86_400).to_f }
  end

  def finished_demands
    @finished_demands ||= @all_projects.map { |project| project.demands.finished_with_leadtime }.flatten.sort_by(&:end_date)
  end
end
