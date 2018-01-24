# frozen_string_literal: true

class ReportData
  attr_reader :projects, :weeks, :ideal, :current, :scope

  def initialize(projects)
    @projects = projects
    @weeks = projects_weeks
    @ideal = []
    @current = []
    @scope = []
    mount_data
  end

  def projects_names
    projects.map(&:full_name)
  end

  def hours_per_demand_chart_data_for_week(ordered_project_results)
    result_data = []
    @weeks.each { |week| result_data << ordered_project_results.for_week(week[0], week[1]).sum(&:hours_per_demand) if add_data_to_chart?(week) }
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

  def mount_data
    total_delivered = 0

    @weeks.each_with_index do |week, index|
      @ideal << ideal_burn(index)
      total_delivered += ProjectResultsRepository.instance.th_in_week_for_projects(projects, week[0], week[1])
      @current << total_delivered if add_data_to_chart?(week)
      @scope << ProjectResultsRepository.instance.scope_in_week_for_projects(projects, week[0], week[1])
    end
  end

  def ideal_burn(index)
    (@projects.sum(&:current_backlog).to_f / @weeks.count.to_f) * (index + 1)
  end

  def add_data_to_chart?(week)
    week[1] < Time.zone.today.cwyear || (week[0] <= Time.zone.today.cweek && week[1] <= Time.zone.today.cwyear)
  end
end
