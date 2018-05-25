# frozen_string_literal: true

class ChartData
  attr_reader :all_projects, :active_projects, :all_projects_weeks, :active_weeks, :all_projects_months, :active_months

  def initialize(projects)
    @all_projects = projects
    @active_projects = projects.active
    build_all_projects_periods
    build_active_projects_periods
  end

  private

  def add_data_to_chart?(week_year)
    week_year[1] < Time.zone.today.cwyear || (week_year[0] <= Time.zone.today.cweek && week_year[1] <= Time.zone.today.cwyear)
  end

  def add_month_data_to_chart?(month_year)
    month_year[1] < Time.zone.today.year || (month_year[0] <= Time.zone.today.month && month_year[1] <= Time.zone.today.year)
  end

  def build_active_projects_periods
    min_date = active_projects.minimum(:start_date)
    max_date = active_projects.maximum(:end_date)
    @active_weeks = build_weeks_array(min_date, max_date)
    @active_months = build_months_array(min_date, max_date)
  end

  def build_all_projects_periods
    min_date = all_projects.minimum(:start_date)
    max_date = all_projects.maximum(:end_date)
    @all_projects_weeks = build_weeks_array(min_date, max_date)
    @all_projects_months = build_months_array(min_date, max_date)
  end

  def build_weeks_array(min_date, max_date)
    array_of_weeks = []

    return [] if min_date.blank? || max_date.blank?

    while min_date <= max_date
      array_of_weeks << [min_date.cweek, min_date.cwyear]
      min_date += 7.days
    end

    array_of_weeks
  end

  def build_months_array(min_date, max_date)
    array_of_months = []

    return [] if min_date.blank? || max_date.blank?

    while min_date <= max_date
      array_of_months << [min_date.month, min_date.year]
      min_date += 1.month
    end

    array_of_months
  end
end
