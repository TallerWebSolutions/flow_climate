# frozen_string_literal: true

module Highchart
  class StatusReportChartsAdapter < HighchartAdapter
    attr_reader :hours_burnup_per_week_data, :hours_burnup_per_month_data, :dates_to_montecarlo_duration, :confidence_95_duration, :confidence_80_duration, :confidence_60_duration,
                :work_item_flow_information

    def initialize(demands, start_date, end_date, chart_period_interval)
      super(demands, start_date, end_date, chart_period_interval)

      @work_item_flow_information = Flow::WorkItemFlowInformations.new(demands_list, uncertain_scope, @x_axis.length, end_date)

      return unless @all_projects.count.positive?

      build_demand_data_processors

      montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo((demands.kept.not_finished.count + uncertain_scope), @work_item_flow_information.throughput_array_for_monte_carlo, 500)
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
      demands = demands_list.order('end_date, commitment_date, created_date')
      teams = demands.map(&:team).uniq
      return [] if teams.count != 1

      stages = teams.first.stages.downstream.where('stages.order >= 0').order(:order)
      demands_stages_count = build_cfd_hash(demands.map(&:id), stages, end_of_period_for_date(Time.zone.today))

      demands_stages_count.map { |key, value| { name: key, data: value } } # build the chart
    end

    private

    def build_cfd_hash(demands_ids, stages, bottom_limit_date)
      demands_stages_count = {}

      @x_axis.each do |date|
        break unless date <= bottom_limit_date

        stages.each do |stage|
          transitions = DemandTransition.for_demands_ids(demands_ids).before_date_after_stage(date.end_of_day, stage.order)
          delivered_count = transitions.map(&:demand_id).uniq.count

          if demands_stages_count[stage.name].present?
            demands_stages_count[stage.name] << delivered_count
          else
            demands_stages_count[stage.name] = [transitions.count]
          end
        end
      end

      demands_stages_count
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

    def build_demand_data_processors
      @x_axis.each_with_index do |analysed_date, distribution_index|
        @work_item_flow_information.work_items_flow_behaviour(@x_axis.first, analysed_date, distribution_index, add_data_to_chart?(analysed_date))
        @work_item_flow_information.build_cfd_hash(@x_axis.first, analysed_date) if analysed_date <= Time.zone.today.end_of_week
      end
    end

    def project_start_date
      @project_start_date ||= @all_projects.minimum(:start_date)
    end

    def project_end_date
      @project_end_date ||= @all_projects.maximum(:end_date)
    end
  end
end
