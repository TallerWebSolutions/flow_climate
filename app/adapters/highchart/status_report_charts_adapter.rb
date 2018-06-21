# frozen_string_literal: true

module Highchart
  class StatusReportChartsAdapter < HighchartAdapter
    attr_reader :hours_burnup_per_week_data, :hours_burnup_per_month_data, :monte_carlo_data

    def initialize(projects)
      super(projects)
      @hours_burnup_per_week_data = Highchart::BurnupChartsAdapter.new(@active_weeks, build_hours_scope_data_per_week, build_hours_throughput_data_week)
      @hours_burnup_per_month_data = Highchart::BurnupChartsAdapter.new(@active_months, build_hours_scope_data_per_month, build_hours_throughput_data_month)

      project = projects.first
      build_montecarlo_data(project)
    end

    def throughput_per_week
      upstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(all_projects, :upstream)
      downstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(all_projects, :downstream)

      throughput_chart_data(downstream_th_weekly_data, upstream_th_weekly_data)
    end

    def delivered_vs_remaining
      [{ name: I18n.t('projects.show.delivered_demands.text'), data: [@all_projects.sum(&:total_throughput)] }, { name: I18n.t('projects.show.scope_gap'), data: [@all_projects.sum(&:total_gap)] }]
    end

    def deadline
      min_date = all_projects.minimum(:start_date)
      max_date = all_projects.maximum(:end_date)
      passed_time = (Time.zone.today - min_date).to_i + 1
      remaining_days = (max_date - Time.zone.today).to_i + 1
      [{ name: I18n.t('projects.index.total_remaining_days'), data: [remaining_days] }, { name: I18n.t('projects.index.passed_time'), data: [passed_time], color: '#F45830' }]
    end

    def hours_per_stage
      hours_per_stage_distribution = ProjectsRepository.instance.hours_per_stage(@all_projects)
      hours_per_stage_chart_hash = {}
      hours_per_stage_chart_hash[:xcategories] = hours_per_stage_distribution.map { |hours_per_stage_array| hours_per_stage_array[0] }
      hours_per_stage_chart_hash[:hours_per_stage] = hours_per_stage_distribution.map { |hours_per_stage_array| hours_per_stage_array[2] / 3600 }
      hours_per_stage_chart_hash
    end

    def dates_and_odds
      return {} if @active_projects.blank?
      project = @active_projects.first
      build_deadline_odds_data(monte_carlo_data, project)
    end

    private

    def build_montecarlo_data(project)
      @monte_carlo_data = if project.present?
                            Stats::StatisticsService.instance.run_montecarlo(project.demands.count, gather_leadtime_data(project), gather_throughput_data(project), 100)
                          else
                            Stats::Presenter::MonteCarloPresenter.new({})
                          end
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

    def date_hash_matches?(key, week_year)
      key.to_date.cweek == week_year[0] && key.to_date.cwyear == week_year[1]
    end

    def build_hours_scope_data_per_week
      scope_per_week = []
      @all_projects_weeks.each { |_week_year| scope_per_week << @all_projects.sum(:qty_hours).to_f }
      scope_per_week
    end

    def build_hours_scope_data_per_month
      scope_per_month = []
      @all_projects_months.each { |_week_year| scope_per_month << @all_projects.sum(:qty_hours).to_f }
      scope_per_month
    end

    def build_hours_throughput_data_week
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

    def build_hours_throughput_data_month
      throughput_per_month = []
      @all_projects_months.each do |month_year|
        month = month_year[0]
        year = month_year[1]
        upstream_total_delivered = delivered_to_projects_and_stream_until_month(month, year, all_projects, :qty_hours_upstream)
        downstream_total_delivered = delivered_to_projects_and_stream_until_month(month, year, all_projects, :qty_hours_downstream)
        throughput_per_month << upstream_total_delivered + downstream_total_delivered if add_month_data_to_chart?(month_year)
      end
      throughput_per_month
    end

    def delivered_to_projects_and_stream_until_week(week, year, projects, metric_field)
      ProjectResult.until_week(week, year).where(project_id: projects.map(&:id)).sum(metric_field)
    end

    def delivered_to_projects_and_stream_until_month(month, year, projects, metric_field)
      ProjectResult.until_month(month, year).where(project_id: projects.map(&:id)).sum(metric_field)
    end
  end
end
