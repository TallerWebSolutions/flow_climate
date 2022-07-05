# frozen_string_literal: true

class DemandService
  include Singleton

  def lead_time_breakdown(demands)
    transitions_array = demands.map { |demand| demand.demand_transitions.includes([:stage]).where(stages: { stage_stream: :downstream, end_point: false }) }.flatten
    transitions_array.sort_by { |transition| transition.stage.order }.group_by { |transition| transition.stage.name }
  end

  def search_engine(demands, start_date, end_date, search_text, demand_state, demand_type, demand_class_of_service, demand_tags, team_id)
    demands_list = demands
    demands_list = demands.to_dates(start_date.to_date, end_date.to_date) if start_date.present? && end_date.present?
    demands_list = DemandsRepository.instance.filter_demands_by_text(demands_list, search_text)
    demands_list = DemandsRepository.instance.team_query(demands_list, team_id)

    demands_list = DemandsRepository.instance.demand_state_query(demands_list, demand_state)
    demands_list = DemandsRepository.instance.demand_type_query(demands_list, demand_type)
    demands_list = DemandsRepository.instance.demand_tags_query(demands_list, demand_tags)
    DemandsRepository.instance.class_of_service_query(demands_list, demand_class_of_service)
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

  def average_speed(demands)
    demands_finished = demands.kept.finished_until_date(Time.zone.now)
    min_date = demands_finished.filter_map(&:end_date).min
    return 0 if min_date.blank?

    max_date = max_date(demands_finished)

    difference_in_days = (max_date.to_date - min_date.to_date).to_i + 1

    demands_finished.count / difference_in_days.to_f
  end

  def similar_p80_project(demand)
    project = demand.project
    demands = project.demands.kept.finished_with_leadtime.where(work_item_type: demand.work_item_type, class_of_service: demand.class_of_service)

    Stats::StatisticsService.instance.percentile(80, demands.map(&:leadtime))
  end

  def similar_p80_team(demand)
    team = demand.team
    limit_date = [10.weeks.ago, demand.project.start_date].min
    demands = team.demands.kept.finished_with_leadtime.finished_after_date(limit_date).where(work_item_type: demand.work_item_type, class_of_service: demand.class_of_service)

    Stats::StatisticsService.instance.percentile(80, demands.map(&:leadtime))
  end

  def build_throughput_per_period_array(demands, start_date, end_date)
    dates_array = TimeService.instance.weeks_between_of(start_date, end_date)
    demands_throughputs = Demand.where(id: demands.kept.order(:end_date).map(&:id))
                                .group('EXTRACT(week FROM demands.end_date)::INTEGER')
                                .group('EXTRACT(isoyear FROM demands.end_date)::INTEGER')
                                .count

    process_dates(dates_array, demands_throughputs)
  end

  private

  def process_dates(dates_array, demands_throughputs)
    throughput_per_period_array = []

    dates_array.each do |analysed_date|
      week = analysed_date.cweek
      year = analysed_date.cwyear

      throughput_per_period_array << if demands_throughputs[[week, year]].present?
                                       demands_throughputs[[week, year]]
                                     else
                                       0
                                     end
    end

    throughput_per_period_array
  end

  def max_date(demands_finished)
    [demands_finished.filter_map(&:end_date).max, Time.zone.now.end_of_day].compact.max
  end
end
