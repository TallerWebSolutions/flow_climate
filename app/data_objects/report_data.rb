# frozen_string_literal: true

class ReportData < ChartData
  attr_reader :demands_burnup_data, :hours_burnup_data, :flow_pressure_data, :monte_carlo_data

  def initialize(projects)
    @projects = projects
    @weeks = projects_weeks
    @flow_pressure_data = []
    @demands_burnup_data = BurnupData.new(@weeks, mount_demands_scope_data, mount_demands_throughput_data)
    @hours_burnup_data = BurnupData.new(@weeks, mount_hours_scope_data, mount_hours_throughput_data)

    project = projects.first
    @monte_carlo_data = Stats::StatisticsService.instance.run_montecarlo(project.demands.count, gather_leadtime_data(project), gather_throughput_data(project), 500) if project.present?
    mount_flow_pressure_array
  end

  def projects_names
    projects.map(&:full_name)
  end

  def hours_per_demand_per_week
    weekly_data = ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects(projects)

    result_data = []
    @weeks.each do |week_year|
      break unless add_data_to_chart?(week_year)
      keys_matching = weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      result_data << (weekly_data[keys_matching.first] || 0)
    end
    result_data
  end

  def throughput_per_week
    upstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(projects, :upstream)
    downstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(projects, :downstream)

    throughput_chart_data(downstream_th_weekly_data, upstream_th_weekly_data)
  end

  def delivered_vs_remaining
    [{ name: I18n.t('projects.show.delivered_scope'), data: [@projects.sum(&:total_throughput)] }, { name: I18n.t('projects.show.scope_gap'), data: [projects.sum(&:total_gap)] }]
  end

  def deadline
    min_date = projects.minimum(:start_date)
    max_date = projects.maximum(:end_date)
    passed_time = (Time.zone.today - min_date).to_i + 1
    remaining_days = (max_date - Time.zone.today).to_i + 1
    [{ name: I18n.t('projects.index.total_remaining_days'), data: [remaining_days] }, { name: I18n.t('projects.index.passed_time'), data: [passed_time], color: '#F45830' }]
  end

  def average_demand_cost
    weekly_data = ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects(projects)

    result_data = []
    @weeks.each do |week_year|
      break unless add_data_to_chart?(week_year)
      keys_matching = weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      result_data << (weekly_data[keys_matching.first] || 0)
    end
    result_data
  end

  def dates_and_odds
    project = @projects.first
    mount_deadline_odds_data(monte_carlo_data, project)
  end

  def effort_hours_per_month
    project = projects.first
    grouped_hours_to_upstream = DemandsRepository.instance.grouped_by_effort_upstream_per_month([project])
    grouped_hours_to_downstream = DemandsRepository.instance.grouped_by_effort_downstream_per_month([project])

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

  def mount_deadline_odds_data(monte_carlo_data, project)
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
    @weeks.each do |week_year|
      break unless add_data_to_chart?(week_year)
      upstream_keys_matching = upstream_th_weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      upstream_result_data << (upstream_th_weekly_data[upstream_keys_matching.first] || 0)

      downstream_keys_matching = downstream_th_weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      downstream_result_data << (downstream_th_weekly_data[downstream_keys_matching.first] || 0)
    end
    [{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: downstream_result_data }]
  end

  def date_hash_matches?(key, week_year)
    key.to_date.cweek == week_year[0] && key.to_date.cwyear == week_year[1]
  end

  def mount_flow_pressure_array
    weekly_data = ProjectResultsRepository.instance.flow_pressure_in_week_for_projects(projects)

    @weeks.each do |week_year|
      begining_of_week = Date.commercial(week_year[1], week_year[0], 1)
      keys_matching = weekly_data.keys.select { |key| date_hash_matches?(key, week_year) }
      add_actual_or_projected_data(begining_of_week, keys_matching, weekly_data)
    end
  end

  def add_actual_or_projected_data(begining_of_week, keys_matching, weekly_data)
    @flow_pressure_data << (weekly_data[keys_matching.first].to_f || 0.0) if keys_matching.present? || begining_of_week <= Time.zone.today
    @flow_pressure_data << projects.sum { |p| p.flow_pressure(begining_of_week) } / projects.count.to_f if begining_of_week.future?
  end

  def mount_demands_scope_data
    scope_per_week = []
    @weeks.each do |week_year|
      scope_per_week << ProjectResultsRepository.instance.scope_in_week_for_projects(projects, week_year[0], week_year[1])
    end
    scope_per_week
  end

  def mount_demands_throughput_data
    throughput_per_week = []
    @weeks.each do |week_year|
      week = week_year[0]
      year = week_year[1]
      upstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, projects, :throughput_upstream)
      downstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, projects, :throughput_downstream)
      throughput_per_week << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(week_year)
    end
    throughput_per_week
  end

  def mount_hours_scope_data
    scope_per_week = []
    @weeks.each { |_week_year| scope_per_week << @projects.sum(:qty_hours).to_f }
    scope_per_week
  end

  def mount_hours_throughput_data
    throughput_per_week = []
    @weeks.each do |week_year|
      week = week_year[0]
      year = week_year[1]
      upstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, projects, :qty_hours_upstream)
      downstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, projects, :qty_hours_downstream)
      throughput_per_week << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(week_year)
    end
    throughput_per_week
  end

  def delivered_to_projects_and_stream_until_week(week, year, projects, metric_field)
    ProjectResult.until_week(week, year).where(project_id: projects.pluck(:id)).sum(metric_field)
  end
end
