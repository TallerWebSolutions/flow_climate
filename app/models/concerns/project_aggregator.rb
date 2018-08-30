# frozen_string_literal: true

module ProjectAggregator
  extend ActiveSupport::Concern

  def active_projects
    projects.running
  end

  def waiting_projects
    projects.where(status: :waiting)
  end

  def last_week_scope
    projects.sum(&:last_week_scope)
  end

  def avg_hours_per_demand
    projects_with_data = projects.select { |p| p.avg_hours_per_demand.positive? }
    return 0 if projects_with_data.size.zero?
    projects_with_data.sum(&:avg_hours_per_demand) / projects_with_data.size.to_f
  end

  def average_demand_cost
    return 0 if projects_count.zero?
    projects.sum(&:average_demand_cost) / projects_count.to_f
  end

  def total_value
    projects.sum(&:value)
  end

  def remaining_money
    projects.sum(&:remaining_money)
  end

  def percentage_remaining_money
    return 0 if total_value.zero?
    (remaining_money / total_value) * 100
  end

  def backlog_remaining
    projects.sum(&:backlog_remaining)
  end

  def percentage_remaining_scope
    return 0 if last_week_scope.zero?
    (backlog_remaining.to_f / last_week_scope.to_f) * 100
  end

  def total_flow_pressure
    projects.sum(&:flow_pressure)
  end

  def delivered_scope
    projects.sum(&:total_throughput)
  end
end
