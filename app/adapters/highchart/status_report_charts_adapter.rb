# frozen_string_literal: true

module Highchart
  class StatusReportChartsAdapter < HighchartAdapter
    attr_reader :hours_burnup_per_week_data, :hours_burnup_per_month_data, :dates_to_montecarlo_duration, :confidence_95_duration, :confidence_80_duration, :confidence_60_duration

    def initialize(projects, start_date, end_date, chart_period_interval)
      super(projects, start_date, end_date, chart_period_interval)

      return unless @all_projects.count.positive?

      montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(@all_projects.active.sum(&:remaining_backlog), gather_throughput_data.values, 500)
      build_montecarlo_perecentage_confidences(montecarlo_durations)
      build_dates_to_montecarlo_duration_chart_hash

      @hours_burnup_per_week_data = Highchart::BurnupChartsAdapter.new(@x_axis, build_hours_scope_data_per_week, build_hours_throughput_data_week)
      @hours_burnup_per_month_data = Highchart::BurnupChartsAdapter.new(@x_axis, build_hours_scope_data_per_month, build_hours_throughput_data_month)
    end

    def throughput_per_period
      upstream_result_data = []
      downstream_result_data = []
      @x_axis.each do |date|
        break unless date <= end_of_period_for_date(Time.zone.today)

        upstream_result_data << DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'upstream', end_of_period_for_date(date)).count
        downstream_result_data << DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'downstream', end_of_period_for_date(date)).count
      end
      [{ name: I18n.t('projects.charts.throughput.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput.stage_stream.downstream'), data: downstream_result_data }]
    end

    def delivered_vs_remaining
      [{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [@all_projects.sum { |project| project.demands.opened_after_date(@start_date).count }] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [@all_projects.sum { |project| project.demands.finished_after_date(@start_date).count }] }, { name: I18n.t('projects.show.scope_gap'), data: [@all_projects.sum(&:remaining_backlog)] }]
    end

    def deadline
      min_date = project_start_date
      max_date = project_end_date
      return [] if min_date.blank?

      passed_time = (Time.zone.today - min_date).to_i + 1
      remaining_days = (max_date - Time.zone.today).to_i + 1
      [{ name: I18n.t('projects.index.total_remaining_days'), data: [remaining_days] }, { name: I18n.t('projects.index.passed_time'), data: [passed_time], color: '#F45830' }]
    end

    def deadline_vs_montecarlo_durations
      return [] if @all_projects.blank?

      max_date = project_end_date
      remaining_weeks = ((max_date - Time.zone.today).to_i / 7) + 1

      [
        { name: I18n.t('projects.index.total_remaining_weeks'), data: [remaining_weeks] },
        { name: I18n.t('projects.charts.deadline_vs_montecarlo_durations.confidence_95'), data: [@confidence_95_duration] },
        { name: I18n.t('projects.charts.deadline_vs_montecarlo_durations.confidence_80'), data: [@confidence_80_duration] },
        { name: I18n.t('projects.charts.deadline_vs_montecarlo_durations.confidence_60'), data: [@confidence_60_duration] }
      ]
    end

    def hours_per_stage_upstream
      hours_per_stage_distribution = DemandTransitionsRepository.instance.hours_per_stage(@all_projects, :upstream, @start_date)
      build_hours_per_stage_hash(hours_per_stage_distribution)
    end

    def hours_per_stage_downstream
      hours_per_stage_distribution = DemandTransitionsRepository.instance.hours_per_stage(@all_projects, :downstream, @start_date)
      build_hours_per_stage_hash(hours_per_stage_distribution)
    end

    def cumulative_flow_diagram_downstream
      demands_ids = @all_projects.map(&:demands).flatten.map(&:id)
      cumulative_hash = {}

      @x_axis.each do |date|
        break unless date <= end_of_period_for_date(Time.zone.today)

        cumulative_data_to_week = DemandsRepository.instance.cumulative_flow_for_date(demands_ids, @start_date, end_of_period_for_date(date), :downstream)
        cumulative_hash = cumulative_hash.merge(build_cumulative_hash(cumulative_data_to_week, cumulative_hash))
      end

      build_cumulative_array(cumulative_hash)
    end

    def cumulative_flow_diagram_upstream
      demands_ids = @all_projects.map(&:demands).flatten.map(&:id)
      cumulative_hash = {}

      @x_axis.each do |date|
        break unless date <= Time.zone.today

        cumulative_data_to_week = DemandsRepository.instance.cumulative_flow_for_date(demands_ids, @start_date, date, :upstream)

        cumulative_hash = cumulative_hash.merge(build_cumulative_hash(cumulative_data_to_week, cumulative_hash))
      end

      build_cumulative_array(cumulative_hash)
    end

    private

    def build_hours_per_stage_hash(hours_per_stage_distribution)
      hours_per_stage_chart_hash = {}
      hours_per_stage_chart_hash[:xcategories] = hours_per_stage_distribution.map { |hours_per_stage_array| hours_per_stage_array[0] }
      hours_per_stage_chart_hash[:hours_per_stage] = hours_per_stage_distribution.map { |hours_per_stage_array| hours_per_stage_array[2] / 1.hour }
      hours_per_stage_chart_hash
    end

    def build_cumulative_hash(cumulative_data_to_week, previous_cumulative_hash)
      cumulative_hash = previous_cumulative_hash

      cumulative_data_to_week.keys.each do |stage_name|
        if cumulative_hash[stage_name].present?
          cumulative_hash[stage_name] << cumulative_data_to_week[stage_name]
        else
          cumulative_hash[stage_name] = [cumulative_data_to_week[stage_name]]
        end
      end

      cumulative_hash
    end

    def build_cumulative_array(cumulative_hash)
      cumulative_array = []

      max_array_size = cumulative_hash.values.map(&:size).max

      cumulative_hash.each do |key, data|
        data << data.last while data.size < max_array_size
        cumulative_array << { name: key, data: data, marker: { enabled: false } }
      end

      cumulative_array
    end

    def build_montecarlo_perecentage_confidences(montecarlo_durations)
      @confidence_95_duration = Stats::StatisticsService.instance.percentile(95, montecarlo_durations)
      @confidence_80_duration = Stats::StatisticsService.instance.percentile(80, montecarlo_durations)
      @confidence_60_duration = Stats::StatisticsService.instance.percentile(60, montecarlo_durations)
    end

    def build_dates_to_montecarlo_duration_chart_hash
      @dates_to_montecarlo_duration = []
      active_projects = @all_projects.active
      return if active_projects.blank?

      @dates_to_montecarlo_duration << { name: I18n.t('projects.charts.montecarlo_dates.project_date'), date: active_projects.maximum(:end_date), color: '#1E8449' }
      @dates_to_montecarlo_duration << { name: I18n.t('projects.charts.montecarlo_dates.confidence_95'), date: TimeService.instance.add_weeks_to_today(@confidence_95_duration), color: '#B7950B' }
      @dates_to_montecarlo_duration << { name: I18n.t('projects.charts.montecarlo_dates.confidence_80'), date: TimeService.instance.add_weeks_to_today(@confidence_80_duration), color: '#F4D03F' }
      @dates_to_montecarlo_duration << { name: I18n.t('projects.charts.montecarlo_dates.confidence_60'), date: TimeService.instance.add_weeks_to_today(@confidence_60_duration), color: '#CB4335' }
    end

    def gather_throughput_data
      return [] if @all_projects.blank?

      projects_to_throughput_data = @all_projects
      projects_to_throughput_data = @all_projects.first.product.projects.order(:end_date) if @all_projects.size == 1

      throughput_grouped_per_week_hash = DemandsRepository.instance.throughput_to_projects_and_period(projects_to_throughput_data, project_start_date, project_end_date).group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
      DemandInfoDataBuilder.instance.build_data_from_hash_per_week(throughput_grouped_per_week_hash, project_start_date, project_end_date)
    end

    def project_start_date
      @project_start_date ||= @all_projects.minimum(:start_date)
    end

    def project_end_date
      @project_end_date ||= @all_projects.maximum(:end_date)
    end

    def build_hours_scope_data_per_week
      scope_per_week = []
      @x_axis.each { |_week_year| scope_per_week << @all_projects.sum(:qty_hours).to_f }
      scope_per_week
    end

    def build_hours_scope_data_per_month
      scope_per_month = []
      @x_axis.each { |_month_year| scope_per_month << @all_projects.sum(:qty_hours).to_f }
      scope_per_month
    end

    def build_hours_throughput_data_week
      throughput_per_week = []
      @x_axis.each do |date|
        break unless date <= Time.zone.today

        upstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'upstream', date.end_of_week).sum(&:total_effort)
        downstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(@all_projects, 'downstream', date.end_of_week).sum(&:total_effort)
        throughput_per_week << upstream_total_delivered + downstream_total_delivered
      end
      throughput_per_week
    end

    def build_hours_throughput_data_month
      throughput_per_month = []
      @x_axis.each do |date|
        break unless date <= Time.zone.today

        upstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(all_projects, 'upstream', date.end_of_month).sum(&:total_effort)
        downstream_total_delivered = DemandsRepository.instance.delivered_until_date_to_projects_in_stream(all_projects, 'downstream', date.end_of_month).sum(&:total_effort)

        throughput_per_month << upstream_total_delivered + downstream_total_delivered
      end
      throughput_per_month
    end
  end
end
