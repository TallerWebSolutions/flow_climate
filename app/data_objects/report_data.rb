# frozen_string_literal: true

class ReportData < ChartData
  attr_reader :demands_burnup_data, :hours_burnup_data, :flow_pressure_data, :monte_carlo_data,
              :leadtime_bins, :leadtime_histogram_data, :throughput_bins, :throughput_histogram_data,
              :lead_time_control_chart, :weeekly_bugs_count_hash

  def initialize(projects)
    super(projects)
    @flow_pressure_data = []
    @demands_burnup_data = BurnupData.new(@active_weeks, build_demands_scope_data, build_demands_throughput_data)
    @hours_burnup_data = BurnupData.new(@all_projects_weeks, build_hours_scope_data, build_hours_throughput_data)

    project = projects.first
    @monte_carlo_data = if project.present?
                          Stats::StatisticsService.instance.run_montecarlo(project.demands.count, gather_leadtime_data(project), gather_throughput_data(project), 100)
                        else
                          Stats::Presenter::MonteCarloPresenter.new({})
                        end
    build_weeekly_bugs_count_hash
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

  def delivered_vs_remaining
    [{ name: I18n.t('projects.show.delivered_scope.text'), data: [@all_projects.sum(&:total_throughput)] }, { name: I18n.t('projects.show.scope_gap'), data: [@all_projects.sum(&:total_gap)] }]
  end

  def deadline
    min_date = all_projects.minimum(:start_date)
    max_date = all_projects.maximum(:end_date)
    passed_time = (Time.zone.today - min_date).to_i + 1
    remaining_days = (max_date - Time.zone.today).to_i + 1
    [{ name: I18n.t('projects.index.total_remaining_days'), data: [remaining_days] }, { name: I18n.t('projects.index.passed_time'), data: [passed_time], color: '#F45830' }]
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

  def dates_and_odds
    return {} if @active_projects.blank?
    project = @active_projects.first
    build_deadline_odds_data(monte_carlo_data, project)
  end

  def effort_hours_per_month
    grouped_hours_to_upstream = DemandsRepository.instance.grouped_by_effort_upstream_per_month(all_projects)
    grouped_hours_to_downstream = DemandsRepository.instance.grouped_by_effort_downstream_per_month(all_projects)

    hours_per_month_data_hash = {}

    hours_per_month_data_hash[:keys] = grouped_hours_to_upstream.keys | grouped_hours_to_downstream.keys

    data_upstream = []
    data_downstream = []

    hours_per_month_data_hash[:keys].each do |month|
      data_upstream << grouped_hours_to_upstream[month] || 0
      data_downstream << grouped_hours_to_downstream[month] || 0
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

  def gather_leadtime_data(project)
    leadtime_data_array = ProjectsRepository.instance.leadtime_per_week([project]).values
    leadtime_data_array = ProjectsRepository.instance.leadtime_per_week(project.product.projects).values if leadtime_data_array.size < 10
    leadtime_data_array
  end

  def gather_throughput_data(project)
    throughput_data_array = ProjectsRepository.instance.throughput_per_week([project]).values
    throughput_data_array = ProjectsRepository.instance.throughput_per_week(project.product.projects).values if throughput_data_array.size < 10
    throughput_data_array
  end

  def build_deadline_odds_data(monte_carlo_data, project)
    all_montecarlo_dates = monte_carlo_data.monte_carlo_date_hash.keys
    most_likely_montecarlo_date = all_montecarlo_dates.first
    most_likely_montecarlo_odd = monte_carlo_data.monte_carlo_date_hash.values.first

    project_deadline = project.end_date
    project_deadline_odd = monte_carlo_data.monte_carlo_date_hash[project_deadline]
    project_deadline_odd = most_likely_montecarlo_odd if project_deadline_odd.blank? && project_deadline >= most_likely_montecarlo_date

    nearest_montecarlo_date = CollectionsService.find_nearest(all_montecarlo_dates, project_deadline)
    nearest_montecarlo_odd = monte_carlo_data.monte_carlo_date_hash[project_deadline]

    extract_data_and_mount_montecarlo_structure(most_likely_montecarlo_date, most_likely_montecarlo_odd, nearest_montecarlo_date, nearest_montecarlo_odd, project_deadline, project_deadline_odd)
  end

  def extract_data_and_mount_montecarlo_structure(most_likely_montecarlo_date, most_likely_montecarlo_odd, nearest_montecarlo_date, nearest_montecarlo_odd, project_deadline, project_deadline_odd)
    montecarlo_dates_hash = { I18n.t('charts.date_odds.project_date', project_deadline: project_deadline.to_s) => [project_deadline_odd], I18n.t('charts.date_odds.montecarlo_date', montecarlo_deadline: most_likely_montecarlo_date) => [most_likely_montecarlo_odd] }
    montecarlo_dates_hash.merge(I18n.t('charts.date_odds.nearest_montecarlo_date', montecarlo_deadline: nearest_montecarlo_date) => nearest_montecarlo_odd)

    montecarlo_dates_chart_array = []
    montecarlo_dates_hash.sort_by { |key, _value| key }.each do |key, values|
      montecarlo_dates_chart_hash = {}
      montecarlo_dates_chart_hash[:name] = key.to_s
      montecarlo_dates_chart_hash[:data] = values.map { |value| value.to_f * 100 }
      montecarlo_dates_chart_array << montecarlo_dates_chart_hash
    end
    { keys: montecarlo_dates_hash.keys, chart: montecarlo_dates_chart_array }
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
