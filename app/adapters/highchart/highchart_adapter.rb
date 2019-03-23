# frozen_string_literal: true

module Highchart
  class HighchartAdapter
    attr_reader :x_axis, :all_projects, :all_projects_demands_ids, :active_projects_demands_ids, :start_date, :end_date, :chart_period_interval,
                :upstream_operational_weekly_data, :downstream_operational_weekly_data

    def initialize(projects, start_date, end_date, chart_period_interval)
      @start_date = start_date
      @end_date = end_date

      @all_projects = search_projects_by_dates(projects)
      @chart_period_interval = chart_period_interval

      build_x_axis

      @all_projects_demands_ids = @all_projects.map(&:kept_demands_ids).flatten

      @upstream_operational_weekly_data = DemandsRepository.instance.operational_data_per_week_to_projects(@all_projects.map(&:id), false, start_date)
      @downstream_operational_weekly_data = DemandsRepository.instance.operational_data_per_week_to_projects(@all_projects.map(&:id), true, start_date)
    end

    private

    def search_projects_by_dates(projects)
      return projects if @start_date.blank?

      ProjectsRepository.instance.projects_ending_after(projects, @start_date)
    end

    def build_x_axis
      @x_axis = []
      return if @all_projects.blank?

      @x_axis = TimeService.instance.days_between_of(@start_date, @end_date) if @chart_period_interval == 'day'
      @x_axis = TimeService.instance.weeks_between_of(@start_date, @end_date) if @chart_period_interval == 'week'
      @x_axis = TimeService.instance.months_between_of(@start_date, @end_date) if @chart_period_interval == 'month'
    end
  end
end
