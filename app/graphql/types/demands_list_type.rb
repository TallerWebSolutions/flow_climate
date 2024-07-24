# frozen_string_literal: true

module Types
  class DemandsListType < Types::BaseObject
    field :last_page, Boolean, null: false
    field :total_count, Int, null: false
    field :total_pages, Int, null: false

    field :demands, [Types::DemandType], null: false

    field :control_chart, Types::Charts::ControlChartType, null: true
    field :flow_data, Types::Charts::DemandsFlowChartDataType, null: true
    field :flow_efficiency, Types::Charts::SimpleDateChartDataType, null: true
    field :lead_time_breakdown, Types::Charts::LeadTimeBreakdownType, null: true
    field :lead_time_evolution_p80, Types::Charts::SimpleDateChartDataType, null: true
    field :total_effort, Float, null: false

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
      start_date = charts_start_date(flow_demands)
      end_date = charts_end_date(flow_demands)
      Highchart::DemandsChartsAdapter.new(flow_demands.kept, start_date, end_date, 'week')
    end

    def flow_efficiency
      flow_demands = demands
      x_axis = TimeService.instance.weeks_between_of(charts_start_date(flow_demands), charts_end_date(flow_demands))
      time_flow_info = Flow::TimeFlowInformation.new(flow_demands)
      x_axis.each { |analysed_date| time_flow_info.hours_flow_behaviour(analysed_date) }

      { x_axis: x_axis, y_axis: time_flow_info.flow_efficiency }
    end

    def lead_time_evolution_p80
      demands_finished = demands.finished_with_leadtime.order(end_date: :asc)
      lead_times_p80 = []
      x_axis = TimeService.instance.weeks_between_of(charts_start_date(demands_finished), charts_end_date(demands_finished))

      x_axis.each do |analysed_date|
        demands = demands_finished.finished_until_date(analysed_date)
        lead_times_p80 << Stats::StatisticsService.instance.percentile(80, demands.map(&:leadtime))
      end
      { x_axis: x_axis, y_axis: lead_times_p80 }
    end

    private

    def charts_end_date(flow_demands)
      [flow_demands.filter_map(&:end_date).max, Time.zone.today].compact.min
    end

    def charts_start_date(flow_demands)
      [flow_demands.filter_map(&:created_date).min, 8.weeks.ago].compact.min
    end

    def demands
      Demand.where(id: object['demands'].map(&:id)).where(created_date: 1.year.ago..).order(created_date: :asc)
    end
  end
end
