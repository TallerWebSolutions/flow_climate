# frozen_string_literal: true

module Types
  class DemandsListType < Types::BaseObject
    field :last_page, Boolean, null: false
    field :total_count, Int, null: false
    field :total_pages, Int, null: false

    field :demands, [Types::DemandType], null: false

    field :control_chart, Types::Charts::ControlChartType, null: true
    field :flow_data, Types::Charts::DemandsFlowChartDataType, null: true
    field :lead_time_breakdown, Types::Charts::LeadTimeBreakdownType, null: true

    def control_chart
      demands_finished = demands.finished_with_leadtime.order(end_date: :asc)
      lead_times = demands_finished.map(&:leadtime)
      lead_time_p65 = Stats::StatisticsService.instance.percentile(65, lead_times)
      lead_time_p80 = Stats::StatisticsService.instance.percentile(80, lead_times)
      lead_time_p95 = Stats::StatisticsService.instance.percentile(95, lead_times)

      { x_axis: demands_finished.map(&:external_id), lead_time_p65: lead_time_p65, lead_time_p80: lead_time_p80, lead_time_p95: lead_time_p95, lead_times: lead_times }
    end

    def lead_time_breakdown
      lead_time_breakdown = DemandService.instance.lead_time_breakdown(demands)
      breakdown_stages = lead_time_breakdown.keys
      breakdown_values = lead_time_breakdown.values.map { |transitions| (transitions.sum(&:total_seconds_in_transition) / 1.day) }
      { x_axis: breakdown_stages, y_axis: breakdown_values }
    end

    def flow_data
      flow_demands = demands
      start_date = [flow_demands.filter_map(&:created_date).min, 8.weeks.ago].compact.min
      end_date = [flow_demands.filter_map(&:end_date).max, Time.zone.today].compact.min
      Highchart::DemandsChartsAdapter.new(flow_demands.kept, start_date, end_date, 'week')
    end

    private

    def demands
      Demand.where(id: object['demands'].map(&:id)).where('created_date >= :limit_date', limit_date: 1.year.ago).order(created_date: :asc)
    end
  end
end
