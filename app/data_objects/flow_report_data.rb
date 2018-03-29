# frozen_string_literal: true

class FlowReportData
  attr_reader :projects_in_chart, :total_arrived, :total_processed, :projects_demands_selected, :projects_demands_processed, :processing_rate_data,
              :column_chart_data

  def initialize(projects, week, year)
    assign_grouped_raw_data(projects, week, year)
    build_processing_rate_data
  end

  private

  def assign_grouped_raw_data(projects, week, year)
    @projects_demands_selected = DemandsRepository.instance.selected_grouped_by_project_and_week(projects, week, year).group_by(&:project)
    @projects_demands_processed = DemandsRepository.instance.throughput_grouped_by_project_and_week(projects, week, year).group_by(&:project)

    @projects_in_chart = (projects_demands_selected.keys | projects_demands_processed.keys).flatten.uniq
    @processing_rate_data = projects_demands_selected.merge(projects_demands_processed) { |_key, oldval, newval| oldval | newval }
  end

  def build_processing_rate_data
    @total_arrived = []
    @total_processed = []

    projects_in_chart.each do |project_id|
      @total_arrived << (projects_demands_selected[project_id]&.count || 0)
      @total_processed << (projects_demands_processed[project_id]&.count || 0)
    end

    @column_chart_data = [{ name: I18n.t('demands.charts.processing_rate.arrived'), data: @total_arrived }, { name: I18n.t('demands.charts.processing_rate.processed'), data: @total_processed }]
  end
end
