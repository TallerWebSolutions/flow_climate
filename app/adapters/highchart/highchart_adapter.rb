# frozen_string_literal: true

module Highchart
  class HighchartAdapter
    attr_reader :x_axis, :x_axis_index, :all_projects, :start_date, :end_date, :chart_period_interval, :demands_list, :demands

    def initialize(demands, start_date, end_date, chart_period_interval)
      @chart_period_interval = chart_period_interval
      @start_date = TimeService.instance.start_of_period_for_date(start_date, @chart_period_interval)
      @end_date = TimeService.instance.end_of_period_for_date(end_date, @chart_period_interval)

      @all_projects = []
      @all_projects = search_projects_by_dates(demands.map(&:project_id)) if demands.present?

      @demands = demands
      @demands_list = demands.where('(demands.end_date IS NOT NULL AND demands.end_date >= :base_date) OR (demands.commitment_date IS NOT NULL AND demands.commitment_date >= :base_date) OR (demands.created_date IS NOT NULL AND demands.created_date >= :base_date)', base_date: start_date).order(:end_date)

      build_x_axis
    end

    private

    def uncertain_scope
      @uncertain_scope ||= @all_projects.map(&:initial_scope).compact.sum
    end

    def daily?
      @chart_period_interval == 'day'
    end

    def weekly?
      @chart_period_interval == 'week'
    end

    def monthly?
      @chart_period_interval == 'month'
    end

    def search_projects_by_dates(projects_ids)
      projects = Project.where(id: projects_ids)
      return projects if @start_date.blank?

      ProjectsRepository.instance.projects_ending_after(projects, @start_date)
    end

    def build_x_axis
      @x_axis = []
      @x_axis_index = []
      return if @all_projects.blank?

      @x_axis = TimeService.instance.days_between_of(@start_date, @end_date) if daily?
      @x_axis = TimeService.instance.weeks_between_of(@start_date, @end_date) if weekly?
      @x_axis = TimeService.instance.months_between_of(@start_date, @end_date) if monthly?

      @x_axis_index = @x_axis.map { |value| @x_axis.find_index(value) + 1 }.flatten
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
