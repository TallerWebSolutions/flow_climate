# frozen_string_literal: true

module Highchart
  class PortfolioChartsAdapter
    attr_reader :projects, :start_date, :end_date

    def initialize(projects, start_date, end_date, project_status)
      @projects = Project.where(id: projects.map(&:id))
      @projects = @projects.where(status: project_status) if project_status.present?
      @demands = Demand.kept.where(id: @projects.map { |project| project.demands.opened_before_date(Time.zone.now).map(&:id) }.flatten)

      @start_date = start_date
      @end_date = end_date
    end

    def block_count_by_project
      return {} if @start_date.blank? || @end_date.blank?

      block_count_grouped_by_project = DemandBlocksRepository.instance.closed_blocks_to_projects_and_period_grouped(@projects, @start_date, @end_date)
      ordered_by_block_qty = {}
      block_count_grouped_by_project.each { |key, values| ordered_by_block_qty[key] = values.count }

      ordered_by_block_qty_hash = ordered_by_block_qty.sort_by { |_key, value| value }.to_h
      x_axis = ordered_by_block_qty_hash.keys

      { x_axis: x_axis, series: [{ name: I18n.t('portfolio.charts.block_count'), data: ordered_by_block_qty_hash.values, marker: { enabled: true } }] }
    end

    def aging_by_project
      return {} if @projects.blank?

      ordered_projects = @projects.sort_by(&:aging)
      x_axis = ordered_projects.map(&:name)

      { x_axis: x_axis, series: [{ name: I18n.t('portfolio.charts.aging_by_project.data_title'), data: ordered_projects.map(&:aging), marker: { enabled: true } }] }
    end

    def throughput_by_project
      return {} if @start_date.blank? || @end_date.blank?

      throughput_by_project_data = DemandsRepository.instance.demands_delivered_grouped_by_projects_to_period(@demands, @start_date, @end_date).sort.to_h
      x_axis = throughput_by_project_data.keys
      { x_axis: x_axis, series: [{ name: I18n.t('portfolio.charts.throughput_by_project.data_title'), data: throughput_by_project_data.values.map(&:count), marker: { enabled: true } }] }
    end
  end
end
