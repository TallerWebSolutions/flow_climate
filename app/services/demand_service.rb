# frozen_string_literal: true

class DemandService
  include Singleton

  def lead_time_breakdown(demands)
    transitions_array = demands.map { |demand| demand.demand_transitions.joins(:stage).where(stages: { stage_stream: :downstream, end_point: false }) }.flatten
    transitions_array.sort_by { |transition| transition.stage.order }.group_by { |transition| transition.stage.name }
  end

  def search_engine(demands, start_date, end_date, search_text, flow_status, demand_type, demand_class_of_service, demand_tags)
    demands_list_view = demands.kept.to_dates(start_date, end_date)
    demands_list_view = DemandsRepository.instance.filter_demands_by_text(demands_list_view, search_text)

    demands_list_view = DemandsRepository.instance.flow_status_query(demands_list_view, flow_status)
    demands_list_view = DemandsRepository.instance.demand_type_query(demands_list_view, demand_type)
    demands_list_view = DemandsRepository.instance.demand_tags_query(demands_list_view, demand_tags)
    DemandsRepository.instance.class_of_service_query(demands_list_view, demand_class_of_service)
  end

  def hours_per_demand(demands_delivered)
    return 0 if demands_delivered.count.zero?

    hours_delivered = demands_delivered.sum(&:total_effort).to_f
    hours_delivered.to_f / demands_delivered.count
  end

  def flow_efficiency(demands_delivered)
    return 0 if demands_delivered.count.zero?

    queue_time = demands_delivered.sum(&:total_queue_time).to_f / 1.hour
    touch_time = demands_delivered.sum(&:total_touch_time).to_f / 1.hour

    Stats::StatisticsService.instance.compute_percentage(touch_time, queue_time)
  end
end
