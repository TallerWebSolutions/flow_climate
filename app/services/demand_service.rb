# frozen_string_literal: true

class DemandService
  include Singleton

  def lead_time_breakdown(demands)
    transitions_array = demands.map { |demand| demand.demand_transitions.joins(:stage).where(stages: { stage_stream: :downstream, end_point: false }) }.flatten
    transitions_array.sort_by { |transition| transition.stage.order }.group_by { |transition| transition.stage.name }
  end

  def search_engine(demands, start_date, end_date, search_text, flow_status, demand_type, demand_class_of_service)
    demands_list_view = demands.kept.to_dates(start_date, end_date)
    demands_list_view = DemandsRepository.instance.filter_demands_by_text(demands_list_view, search_text)

    demands_list_view = DemandsRepository.instance.flow_status_query(demands_list_view, flow_status)
    demands_list_view = DemandsRepository.instance.demand_type_query(demands_list_view, demand_type)
    DemandsRepository.instance.class_of_service_query(demands_list_view, demand_class_of_service)
  end
end
