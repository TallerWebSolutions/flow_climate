# frozen_string_literal: true

module Highchart
  class StatusReportChartsAdapter < HighchartAdapter
    attr_reader :hours_burnup_per_week_data, :hours_burnup_per_month_data, :dates_to_montecarlo_duration, :confidence_95_duration, :confidence_80_duration, :confidence_60_duration,
                :work_item_flow_information, :stage_level

    def initialize(demands, start_date, end_date, chart_period_interval, stage_level = :team)
      super(demands, start_date, end_date, chart_period_interval)

      @stage_level = stage_level

      @work_item_flow_information = Flow::WorkItemFlowInformation.new(demands_list, uncertain_scope, @x_axis.length, end_date, chart_period_interval)

      return unless @all_projects.count.positive?

      build_demand_data_processors
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

    def cumulative_flow_diagram_downstream
      demands = demands_list.order('end_date, commitment_date, created_date')
      teams = demands.map(&:team).uniq
      return [] if teams.count != 1

      stages = teams.first.stages.downstream.where('stages.order >= 0').order(:order)
      demands_stages_count = build_cfd_hash(demands.map(&:id), stages, TimeService.instance.end_of_period_for_date(Time.zone.today, @chart_period_interval))

      demands_stages_count.map { |key, value| { name: key, data: value } }
    end

    def hours_per_stage
      projects = demands.map(&:project).uniq
      hours_per_stage = DemandTransitionsRepository.instance.hours_per_stage(projects, :downstream, @stage_level, @start_date)

      { x_axis: hours_per_stage.to_h.keys, y_axis: { name: I18n.t('general.hours'), data: hours_per_stage.to_h.values.map { |hours| hours.to_f / 1.hour } } }
    end

    private

    # TODO: remove duplication with WorkItemWorkflowInformation
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
