# frozen_string_literal: true

module DemandsAggregator
  extend ActiveSupport::Concern

  def average_queue_time
    total_queue_time = demands.kept.sum(&:total_queue_time)
    total_demands = demands.kept.count

    return 0 if total_queue_time.zero? || total_demands.zero?

    total_queue_time.to_f / total_demands
  end

  def average_touch_time
    total_touch_time = demands.kept.sum(&:total_touch_time)
    total_demands = demands.kept.count

    return 0 if total_touch_time.zero? || total_demands.zero?

    total_touch_time.to_f / total_demands
  end

  def avg_hours_per_demand
    return 0 unless demands.kept.count.positive?

    demands.kept.filter_map(&:total_effort).sum / demands.kept.count
  end

  def upstream_demands(limit_date = Time.zone.now)
    demands.not_discarded_until(limit_date).not_committed(limit_date) - demands.not_discarded_until(limit_date).not_started(limit_date)
  end

  ##
  # This method returns the percentage of demands with lead time above the demand informed as argument
  # It will return based on everything regardless the type and class of service
  def lead_time_position_percentage(demand)
    demands_without_tested_demand = demands.kept.where.not(id: demand.id)
    return 0 if demands_without_tested_demand.blank?

    compute_demand_lead_time_position(demands_without_tested_demand, demand)
  end

  ##
  # This method returns the percentage of demands, within the same type, with lead time above the demand informed as argument
  # It will return based on the informed demand type
  def lead_time_position_percentage_same_type(demand)
    demands_without_tested_demand = demands.where(demand_type: demand.demand_type).kept.where.not(id: demand.id)
    return 0 if demands_without_tested_demand.blank?

    compute_demand_lead_time_position(demands_without_tested_demand, demand)
  end

  ##
  # This method returns the percentage of demands, within the same class of service, with lead time above the demand informed as argument
  # It will return based on the informed demand class of service
  def lead_time_position_percentage_same_cos(demand)
    demands_without_tested_demand = demands.where(class_of_service: demand.class_of_service).kept.where.not(id: demand.id)
    return 0 if demands_without_tested_demand.blank?

    compute_demand_lead_time_position(demands_without_tested_demand, demand)
  end

  private

  def compute_demand_lead_time_position(demands, demand)
    worse_lead_times_count = demands.where('leadtime > :lead_time_limit', lead_time_limit: demand.leadtime).count

    worse_lead_times_count.to_f / demands.count
  end
end
