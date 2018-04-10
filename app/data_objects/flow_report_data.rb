# frozen_string_literal: true

class FlowReportData
  attr_reader :projects_in_chart, :total_arrived, :total_processed_upstream, :total_processed_downstream,
              :projects_demands_selected, :projects_demands_processed, :processing_rate_data, :column_chart_data,
              :wip_per_day, :demands_in_wip

  def initialize(projects, week, year)
    @total_arrived = []
    @total_processed_upstream = []
    @total_processed_downstream = []

    assign_grouped_raw_data(projects, week, year)
    build_processing_rate_data
    group_wip_data(projects, week, year)
  end

  private

  def assign_grouped_raw_data(projects, week, year)
    @projects_demands_selected = DemandsRepository.instance.selected_grouped_by_project_and_week(projects, week, year).group_by(&:project)
    @projects_demands_processed = DemandsRepository.instance.throughput_by_project_and_week(projects, week, year).group_by(&:project)

    @projects_in_chart = (projects_demands_selected.keys | projects_demands_processed.keys).flatten.uniq
    @processing_rate_data = projects_demands_selected.merge(projects_demands_processed) { |_key, oldval, newval| oldval | newval }
  end

  def group_wip_data(projects, week, year)
    lower_date_limit = Date.commercial(year, week, 1).beginning_of_week
    upper_date_limit = Date.commercial(year, week, 1).end_of_week
    wip_per_day = {}
    @demands_in_wip = {}
    (lower_date_limit..upper_date_limit).each do |analysed_date|
      wip_per_day[analysed_date] = DemandsRepository.instance.work_in_progress_for(projects, analysed_date).count
      @demands_in_wip[analysed_date.to_s] = DemandsRepository.instance.work_in_progress_for(projects, analysed_date)
    end
    @wip_per_day = [{ name: I18n.t('demands.charts.wip_per_day.ylabel'), data: wip_per_day.values }]
  end

  def build_processing_rate_data
    projects_in_chart.each do |project_id|
      @total_arrived << (@projects_demands_selected[project_id]&.count || 0)
      @total_processed_upstream << (@projects_demands_processed[project_id]&.select { |demand| !demand.downstream? }&.count || 0)
      @total_processed_downstream << (@projects_demands_processed[project_id]&.select(&:downstream?)&.count || 0)
    end

    build_processed_demand_column_data
  end

  def build_processed_demand_column_data
    @column_chart_data = [{ name: I18n.t('demands.charts.processing_rate.arrived'), data: @total_arrived, stack: 0, yaxis: 0 },
                          { name: I18n.t('demands.charts.processing_rate.processed_downstream'), data: @total_processed_downstream, stack: 1, yaxis: 1 },
                          { name: I18n.t('demands.charts.processing_rate.processed_upstream'), data: @total_processed_upstream, stack: 1, yaxis: 1 }]
  end
end
