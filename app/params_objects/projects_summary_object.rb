# frozen_string_literal: true

class ProjectsSummaryObject
  attr_reader :projects, :total_hours, :total_consumed_hours, :average_hour_value, :total_value, :total_days, :total_remaining_days, :total_flow_pressure

  def initialize(projects)
    @projects = projects
    @total_hours = projects.sum(&:qty_hours)
    @total_consumed_hours = projects.sum(&:consumed_hours)
    @average_hour_value = projects.average(:hour_value)
    @total_value = projects.sum(&:value)
    @total_days = projects.sum(&:total_days)
    @total_remaining_days = projects.sum(&:remaining_days)
    @total_flow_pressure = projects.sum(&:flow_pressure)
  end

  def percentage_hours_consumed
    return 0 if @total_hours.zero?
    (@total_consumed_hours / @total_hours) * 100
  end
end
