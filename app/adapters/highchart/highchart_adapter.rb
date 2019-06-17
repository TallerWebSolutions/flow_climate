# frozen_string_literal: true

module Highchart
  class HighchartAdapter
    attr_reader :x_axis, :all_projects, :active_projects_demands_ids, :start_date, :end_date, :chart_period_interval

    def initialize(projects, start_date, end_date, chart_period_interval)
      @start_date = start_date
      @end_date = end_date

      @all_projects = search_projects_by_dates(projects)
      @chart_period_interval = chart_period_interval

      build_x_axis
    end

    private

    def daily?
      @chart_period_interval == 'day'
    end

    def weekly?
      @chart_period_interval == 'week'
    end

    def monthly?
      @chart_period_interval == 'month'
    end

    def search_projects_by_dates(projects)
      return projects if @start_date.blank?

      ProjectsRepository.instance.projects_ending_after(projects, @start_date)
    end

    def build_x_axis
      @x_axis = []
      return if @all_projects.blank?

      @x_axis = TimeService.instance.days_between_of(@start_date, @end_date) if daily?
      @x_axis = TimeService.instance.weeks_between_of(@start_date, @end_date) if weekly?
      @x_axis = TimeService.instance.months_between_of(@start_date, @end_date) if monthly?
    end

    def start_of_period_for_date(date)
      return date.beginning_of_day if daily?
      return date.beginning_of_week if weekly?

      date.beginning_of_month
    end

    def end_of_period_for_date(date)
      return date.end_of_day if daily?
      return date.end_of_week if weekly?

      date.end_of_month
    end

    def add_data_to_chart?(date)
      limit_date = if daily?
                     Time.zone.today.end_of_day
                   elsif weekly?
                     Time.zone.today.end_of_week
                   else
                     Time.zone.today.end_of_month
                   end

      date <= limit_date
    end
  end
end
