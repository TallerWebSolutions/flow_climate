# frozen_string_literal: true

module Highchart
  class ProjectStatisticsChartsAdapter < HighchartAdapter
    attr_reader :projects

    def initialize(projects, start_date, end_date, chart_period_interval, project_status)
      @projects = Project.where(id: projects.map(&:id))
      @demands = Demand.kept.where(id: @projects.map { |project| project.demands.map(&:id) }.flatten)

      super(@demands, start_date, end_date, chart_period_interval)

      @projects = @projects.where(status: project_status) if project_status.present?

      build_demand_data_processors
    end

    def scope_data_evolution_chart
      [{ name: I18n.t('projects.general.scope'), data: @work_item_flow_information.scope_per_period, marker: { enabled: true } }]
    end

    def leadtime_data_evolution_chart(confidence)
      accumulated_leadtime_in_time = []
      leadtime_in_week = []

      @x_axis.each do |x_axis_date|
        break unless add_data_to_chart?(x_axis_date)

        start_date = start_of_period_for_date(x_axis_date)
        end_date = end_of_period_for_date(x_axis_date)

        accumulated_leadtime_in_time << build_accumulated_lead_time(confidence, end_date)
        leadtime_in_week << build_lead_time_in_period(confidence, end_date, start_date)
      end

      [{ name: I18n.t('projects.general.accumulated_leadtime', percentil: confidence), data: accumulated_leadtime_in_time, marker: { enabled: true } }, name: I18n.t('projects.general.leadtime', percentil: confidence), data: leadtime_in_week, marker: { enabled: true }]
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

    private

    def build_accumulated_lead_time(confidence, end_date)
      demands_to_period = DemandsRepository.instance.throughput_to_period(@demands, @start_date, end_date)
      Stats::StatisticsService.instance.percentile(confidence, demands_to_period.map(&:leadtime_in_days))
    end

    def build_lead_time_in_period(confidence, end_date, start_date)
      demands_in_period = DemandsRepository.instance.throughput_to_period(@demands, start_date, end_date)
      Stats::StatisticsService.instance.percentile(confidence, demands_in_period.map(&:leadtime_in_days))
    end

    def build_demand_data_processors
      @work_item_flow_information = Flow::WorkItemFlowInformations.new(demands_list, uncertain_scope, @x_axis.length, @x_axis.last)
      @x_axis.each_with_index do |analysed_date, distribution_index|
        @work_item_flow_information.work_items_flow_behaviour(@x_axis.first, analysed_date, distribution_index, add_data_to_chart?(analysed_date))
        @work_item_flow_information.build_cfd_hash(@x_axis.first, analysed_date)
      end
    end
  end
end
