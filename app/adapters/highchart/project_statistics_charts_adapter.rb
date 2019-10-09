# frozen_string_literal: true

module Highchart
  class ProjectStatisticsChartsAdapter < HighchartAdapter
    attr_reader :projects

    def initialize(projects, start_date, end_date, chart_period_interval, project_status)
      @projects = Project.where(id: projects.map(&:id))

      super(@projects, start_date, end_date, chart_period_interval)

      @projects = @projects.where(status: project_status) if project_status.present?
    end

    def scope_data_evolution_chart
      demands_list = Demand.kept.where(id: @projects.map { |project| project.demands.opened_before_date(Time.zone.now).map(&:id) }.flatten)
      @work_item_flow_information = Flow::WorkItemFlowInformations.new(@x_axis, end_of_period_for_date(Time.zone.now), demands_list, @projects.sum(&:initial_scope))

      [{ name: I18n.t('projects.general.scope'), data: @work_item_flow_information.scope_per_period, marker: { enabled: true } }]
    end

    def leadtime_data_evolution_chart(confidence)
      accumulated_leadtime_in_time = []

      @x_axis.each do |x_axis_date|
        break unless add_data_to_chart?(x_axis_date)

        end_date = end_of_period_for_date(x_axis_date)

        demands_to_period = DemandsRepository.instance.throughput_to_projects_and_period(@projects, @start_date, end_date)
        accumulated_leadtime_in_time << Stats::StatisticsService.instance.percentile(confidence, demands_to_period.map(&:leadtime_in_days))
      end

      [{ name: I18n.t('projects.general.leadtime', percentil: confidence), data: accumulated_leadtime_in_time, marker: { enabled: true } }]
    end

    def block_data_evolution_chart
      accumulated_block_in_time = []

      @x_axis.each do |x_axis_date|
        break unless add_data_to_chart?(x_axis_date)

        end_date = end_of_period_for_date(x_axis_date)

        accumulated_block_in_time << DemandBlocksRepository.instance.accumulated_blocks_to_date(@projects, end_date)
      end

      [{ name: I18n.t('projects.statistics.accumulated_blocks.data_title'), data: accumulated_block_in_time, marker: { enabled: true } }]
    end
  end
end
