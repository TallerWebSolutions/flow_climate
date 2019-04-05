# frozen_string_literal: true

class PortfolioStatisticsData
  attr_reader :block_by_project_data, :block_by_project_x_axis, :block_by_project_variation,
              :aging_by_project_data, :aging_by_project_x_axis, :aging_by_project_variation

  def initialize(portfolio_statistics_chart_adapter)
    build_block_by_project_data(portfolio_statistics_chart_adapter)
    build_aging_by_project_data(portfolio_statistics_chart_adapter)
  end

  private

  def build_block_by_project_data(portfolio_statistics_chart_adapter)
    @block_by_project_data = portfolio_statistics_chart_adapter.block_count_by_project[:series]
    @block_by_project_x_axis = portfolio_statistics_chart_adapter.block_count_by_project[:x_axis]

    @block_by_project_variation = Stats::StatisticsService.instance.compute_percentage_variation(@block_by_project_data[0][:data].min || 0, @block_by_project_data[0][:data].max || 0)
  end

  def build_aging_by_project_data(portfolio_statistics_chart_adapter)
    @aging_by_project_data = portfolio_statistics_chart_adapter.aging_by_project[:series]
    @aging_by_project_x_axis = portfolio_statistics_chart_adapter.aging_by_project[:x_axis]

    @aging_by_project_variation = Stats::StatisticsService.instance.compute_percentage_variation(@aging_by_project_data[0][:data].min || 0, @aging_by_project_data[0][:data].max || 0)
  end
end
