# frozen_string_literal: true

module Highchart
  class PortfolioChartsAdapter
    attr_reader :projects, :start_date, :end_date, :x_axis

    def initialize(projects, start_date, end_date)
      @projects = projects

      @start_date = start_date
      @end_date = end_date
    end

    def block_count_per_project
      block_count_grouped_by_project = DemandBlocksRepository.instance.blocks_to_projects_and_period(@projects, @start_date, @end_date)
      ordered_by_block_qty = {}
      block_count_grouped_by_project.each { |key, values| ordered_by_block_qty[key] = values.count }

      ordered_by_block_qty_hash = ordered_by_block_qty.sort_by { |_key, value| value }.to_h

      @x_axis = ordered_by_block_qty_hash.keys
      [{ name: I18n.t('portfolio.charts.block_count'), data: ordered_by_block_qty_hash.values, marker: { enabled: true } }]
    end
  end
end
