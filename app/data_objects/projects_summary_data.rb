# frozen_string_literal: true

class ProjectsSummaryData
  attr_reader :projects, :total_initial_scope, :total_last_week_scope, :total_delivered_scope, :total_hours, :total_consumed_hours, :average_hour_value, :total_value,
              :total_days, :total_remaining_money, :total_remaining_days, :total_flow_pressure

  def initialize(projects)
    @projects = projects
    @total_initial_scope = projects&.sum(:initial_scope)
    @total_delivered_scope = projects&.sum(&:total_throughput)
    @total_last_week_scope = projects&.sum(&:last_week_scope)
    @total_hours = projects&.sum(&:qty_hours)
    @total_consumed_hours = projects&.sum(&:consumed_hours)
    @average_hour_value = projects&.average(:hour_value)
    @total_value = projects&.sum(&:value)
    @total_days = projects&.sum(&:total_days)
    @total_remaining_money = projects&.sum(&:remaining_money)
    @total_remaining_days = projects&.sum(&:remaining_days)
    @total_flow_pressure = projects&.sum(&:flow_pressure)
  end

  def percentage_remaining_money
    return 0 if @total_value.zero?

    (@total_remaining_money.to_f / @total_value.to_f) * 100
  end

  def percentage_remaining_days
    return 0 if @total_days.zero?

    (@total_remaining_days.to_f / @total_days.to_f) * 100
  end

  def remaining_backlog
    @total_last_week_scope - @total_delivered_scope
  end
end
