# frozen_string_literal: true

class ProjectStatisticsData
  attr_reader :leadtime_confidence_to_charts, :scope_data, :scope_period_variation, :leadtime_data, :leadtime_period_variation,
              :block_data, :block_period_variation

  def initialize(project_statistics_chart_adapter, required_leadtime_confidence)
    @leadtime_confidence_to_charts = required_leadtime_confidence

    build_scope_data(project_statistics_chart_adapter)
    build_leadtime_data(project_statistics_chart_adapter)
    build_block_data(project_statistics_chart_adapter)
  end

  private

  def build_scope_data(project_statistics_chart_adapter)
    @scope_data = project_statistics_chart_adapter.scope_data_evolution_chart
    @scope_period_variation = Stats::StatisticsService.instance.compute_percentage_variation(@scope_data[0][:data].first, @scope_data[0][:data].last)
  end

  def build_leadtime_data(project_statistics_chart_adapter)
    @leadtime_data = project_statistics_chart_adapter.leadtime_data_evolution_chart(@leadtime_confidence_to_charts)
    @leadtime_period_variation = Stats::StatisticsService.instance.compute_percentage_variation(@leadtime_data[0][:data].first, @leadtime_data[0][:data].last)
  end

  def build_block_data(project_statistics_chart_adapter)
    @block_data = project_statistics_chart_adapter.block_data_evolution_chart
    @block_period_variation = Stats::StatisticsService.instance.compute_percentage_variation(@block_data[0][:data].first, @block_data[0][:data].last)
  end
end
