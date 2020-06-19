# frozen_string_literal: true

module ProjectAggregator
  extend ActiveSupport::Concern

  def active_projects
    projects.running
  end

  def last_week_scope
    projects.sum(&:last_week_scope)
  end

  def total_value
    projects.map(&:value).compact.sum
  end

  def remaining_money(end_period)
    projects.map { |project| project.remaining_money(end_period) }.sum
  end

  def percentage_remaining_money(end_period)
    return 0 if total_value.zero?

    (remaining_money(end_period) / total_value) * 100
  end

  def remaining_backlog
    projects.sum(&:remaining_backlog)
  end

  def percentage_remaining_scope
    return 0 if last_week_scope.zero?

    (remaining_backlog.to_f / last_week_scope) * 100
  end

  def total_flow_pressure
    projects.sum(&:flow_pressure)
  end

  def delivered_scope
    projects.sum(&:total_throughput)
  end
end
