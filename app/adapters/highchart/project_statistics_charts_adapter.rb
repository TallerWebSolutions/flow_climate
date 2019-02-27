# frozen_string_literal: true

module Highchart
  class ProjectStatisticsChartsAdapter
    attr_reader :project, :start_date, :end_date, :x_axis, :chart_period_interval

    def initialize(project, start_date, end_date, chart_period_interval)
      @project = project

      @start_date = start_date
      @end_date = end_date

      @chart_period_interval = chart_period_interval

      build_x_axis
    end

    def scope_data_evolution_chart
      accumulated_scope_in_time = []

      @x_axis.each do |x_axis_date|
        end_date = if @chart_period_interval == 'day'
                     x_axis_date.end_of_day
                   elsif @chart_period_interval == 'week'
                     x_axis_date.end_of_week
                   else
                     x_axis_date.end_of_month
                   end

        accumulated_scope_in_time << DemandsRepository.instance.known_scope_to_date(@project, end_date)
      end

      [{ name: 'scope', data: accumulated_scope_in_time, marker: { enabled: true } }]
    end

    private

    def build_x_axis
      @x_axis = TimeService.instance.days_between_of(@start_date, @end_date) if @chart_period_interval == 'day'
      @x_axis = TimeService.instance.weeks_between_of(@start_date, @end_date) if @chart_period_interval == 'week'
      @x_axis = TimeService.instance.months_between_of(@start_date, @end_date) if @chart_period_interval == 'month'
    end
  end
end
