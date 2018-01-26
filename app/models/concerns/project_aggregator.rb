# frozen_string_literal: true

module ProjectAggregator
  extend ActiveSupport::Concern

  def active_projects
    projects.where(status: :executing)
  end

  def waiting_projects
    projects.where(status: :waiting)
  end

  def red_projects
    projects.select(&:red?)
  end

  def current_backlog
    projects.sum(&:current_backlog)
  end

  def avg_hours_per_demand
    return 0 if projects_count.zero?
    projects.sum(&:avg_hours_per_demand) / projects_count.to_f
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

  def total_gap
    projects.sum(&:total_gap)
  end

  def percentage_remaining_scope
    return 0 if current_backlog.zero?
    (total_gap.to_f / current_backlog.to_f) * 100
  end

  def total_flow_pressure
    projects.sum(&:flow_pressure)
  end

  def delivered_scope
    projects.sum(&:total_throughput)
  end
end
