# frozen_string_literal: true

module Highchart
  class StatusReportChartsAdapter < HighchartAdapter
    attr_reader :hours_burnup_per_week_data, :hours_burnup_per_month_data, :dates_to_montecarlo_duration, :confidence_95_duration, :confidence_80_duration, :confidence_60_duration

    def initialize(projects, start_date, end_date, chart_period_interval)
      super(projects, start_date, end_date, chart_period_interval)

      return unless @all_projects.count.positive?

      @work_item_flow_information = Flow::WorkItemFlowInformations.new(@x_axis, end_of_period_for_date(Time.zone.now), demands_list, uncertain_scope)

      montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(@work_item_flow_information.scope_per_period.last, @work_item_flow_information.throughput_per_period, 500)
      build_montecarlo_perecentage_confidences(montecarlo_durations)
      build_dates_to_montecarlo_duration_chart_hash
    end

    def delivered_vs_remaining
      [{ name: I18n.t('projects.show.delivered_demands.opened_in_period'), data: [@work_item_flow_information.scope_per_period.last] }, { name: I18n.t('projects.show.delivered_demands.delivered'), data: [@work_item_flow_information.accumulated_throughput.last] }]
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

    def project_start_date
      @project_start_date ||= @all_projects.minimum(:start_date)
    end

    def project_end_date
      @project_end_date ||= @all_projects.maximum(:end_date)
    end
  end
end
