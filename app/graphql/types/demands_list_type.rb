# frozen_string_literal: true

module Types
  class DemandsListType < Types::BaseObject
    field :last_page, Boolean, null: false
    field :total_count, Int, null: false
    field :total_pages, Int, null: false

    field :demands, [Types::DemandType], null: false

    field :control_chart, Types::Charts::ControlChartType, null: true

    def control_chart
      demands_finished = Demand.where(id: object['demands'].map(&:id)).finished_with_leadtime.order(end_date: :asc)
      lead_times = demands_finished.map(&:leadtime)
      lead_time_p65 = Stats::StatisticsService.instance.percentile(65, lead_times)
      lead_time_p80 = Stats::StatisticsService.instance.percentile(80, lead_times)
      lead_time_p95 = Stats::StatisticsService.instance.percentile(95, lead_times)

      { x_axis: demands_finished.map(&:external_id), lead_time_p65: lead_time_p65, lead_time_p80: lead_time_p80, lead_time_p95: lead_time_p95, lead_times: lead_times }
    end
  end
end
