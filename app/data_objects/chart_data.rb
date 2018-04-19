# frozen_string_literal: true

class ChartData
  attr_reader :projects, :weeks

  def initialize(projects)
    @projects = projects
    @weeks = projects_weeks
  end

  private

  def add_data_to_chart?(week_year)
    week_year[1] < Time.zone.today.cwyear || (week_year[0] <= Time.zone.today.cweek && week_year[1] <= Time.zone.today.cwyear)
  end

  def projects_weeks
    min_date = projects.active.minimum(:start_date)
    max_date = projects.active.maximum(:end_date)
    array_of_weeks = []

    return [] if min_date.blank? || max_date.blank?

    while min_date <= max_date
      array_of_weeks << [min_date.cweek, min_date.cwyear]
      min_date += 7.days
    end

    array_of_weeks
  end
end
