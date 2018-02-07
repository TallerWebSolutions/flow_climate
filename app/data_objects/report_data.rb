# frozen_string_literal: true

class ReportData
  attr_reader :projects, :weeks, :ideal, :current, :scope, :flow_pressure_data

  def initialize(projects)
    @projects = projects
    @weeks = projects_weeks
    @ideal = []
    @current = []
    @scope = []
    @flow_pressure_data = []
    mount_flow_pressure_array
    mount_burnup_data
  end

  def projects_names
    projects.map(&:full_name)
  end

  def hours_per_demand_per_week
    result_data = []
    @weeks.each { |week_year| result_data << ProjectResultsRepository.instance.hours_per_demand_in_time_for_projects(@projects, week_year[0], week_year[1]) if add_data_to_chart?(week_year) }
    result_data
  end

  def throughput_per_week
    result_data = []
    @weeks.each { |week_year| result_data << ProjectResultsRepository.instance.throughput_in_week_for_projects(@projects, week_year[0], week_year[1]) if add_data_to_chart?(week_year) }
    result_data
  end

  def average_demand_cost
    result_data = []
    @weeks.each { |week_year| result_data << ProjectResultsRepository.instance.average_demand_cost_in_week_for_projects(@projects, week_year[0], week_year[1]) if add_data_to_chart?(week_year) }
    result_data
  end

  private

  def projects_weeks
    min_date = projects.minimum(:start_date)
    max_date = projects.maximum(:end_date)
    array_of_weeks = []

    while min_date <= max_date
      array_of_weeks << [min_date.cweek, min_date.cwyear]
      min_date += 7.days
    end

    array_of_weeks
  end

  def mount_burnup_data
    total_delivered = 0

    @weeks.each_with_index do |week_year, index|
      @ideal << ideal_burn(index)
      total_delivered += ProjectResultsRepository.instance.th_in_week_for_projects(projects, week_year[0], week_year[1])
      @current << total_delivered if add_data_to_chart?(week_year)
      @scope << ProjectResultsRepository.instance.scope_in_week_for_projects(projects, week_year[0], week_year[1])
    end
  end

  def ideal_burn(index)
    (@projects.sum(&:last_week_scope).to_f / @weeks.count.to_f) * (index + 1)
  end

  def mount_flow_pressure_array
    @weeks.each { |week_year| @flow_pressure_data << ProjectResultsRepository.instance.flow_pressure_in_week_for_projects(projects, week_year[0], week_year[1]) if add_data_to_chart?(week_year) }
  end

  def add_data_to_chart?(week_year)
    week_year[1] < Time.zone.today.cwyear || (week_year[0] < Time.zone.today.cweek && week_year[1] <= Time.zone.today.cwyear)
  end
end
