# frozen_string_literal: true

module Highchart
  class StatusReportChartsAdapter < HighchartAdapter
    attr_reader :hours_burnup_per_week_data, :hours_burnup_per_month_data, :monte_carlo_data

    def initialize(projects, period)
      super(projects, period)
      @hours_burnup_per_week_data = Highchart::BurnupChartsAdapter.new(@active_weeks, build_hours_scope_data_per_week, build_hours_throughput_data_week)
      @hours_burnup_per_month_data = Highchart::BurnupChartsAdapter.new(@active_months, build_hours_scope_data_per_month, build_hours_throughput_data_month)

      project = projects.first
      build_montecarlo_data(project)
    end

    def throughput_per_week
      upstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(@all_projects, @all_projects_weeks[0], :upstream)
      downstream_th_weekly_data = ProjectResultsRepository.instance.throughput_for_projects_grouped_per_week(@all_projects, @all_projects_weeks[0], :downstream)

      throughput_chart_data(downstream_th_weekly_data, upstream_th_weekly_data)
    end

    def delivered_vs_remaining
      [{ name: I18n.t('projects.show.delivered_demands.text'), data: [@all_projects.sum(&:total_throughput)] }, { name: I18n.t('projects.show.scope_gap'), data: [@all_projects.sum(&:total_gap)] }]
    end

    def deadline
      min_date = @all_projects_weeks[0]
      max_date = @all_projects_weeks.last
      return [] if min_date.blank?
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

    def build_hours_scope_data_per_week
      scope_per_week = []
      @active_weeks.each { |_week_year| scope_per_week << @active_projects.sum(:qty_hours).to_f }
      scope_per_week
    end

    def build_hours_scope_data_per_month
      scope_per_month = []
      @active_months.each { |_month_year| scope_per_month << @active_projects.sum(:qty_hours).to_f }
      scope_per_month
    end

    def build_hours_throughput_data_week
      throughput_per_week = []
      @active_weeks.each do |date|
        week = date.cweek
        year = date.cwyear
        upstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, active_projects, :qty_hours_upstream)
        downstream_total_delivered = delivered_to_projects_and_stream_until_week(week, year, active_projects, :qty_hours_downstream)
        throughput_per_week << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(date)
      end
      throughput_per_week
    end

    def build_hours_throughput_data_month
      throughput_per_month = []
      @active_months.each do |date|
        month = date.month
        year = date.year
        upstream_total_delivered = delivered_to_projects_and_stream_until_month(month, year, active_projects, :qty_hours_upstream)
        downstream_total_delivered = delivered_to_projects_and_stream_until_month(month, year, active_projects, :qty_hours_downstream)
        throughput_per_month << upstream_total_delivered + downstream_total_delivered if add_month_data_to_chart?(date)
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
