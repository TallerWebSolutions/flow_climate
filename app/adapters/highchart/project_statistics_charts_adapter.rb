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

      [{ name: I18n.t('projects.general.scope'), data: accumulated_scope_in_time, marker: { enabled: true } }]
    end

    def leadtime_data_evolution_chart(confidence)
      accumulated_leadtime_in_time = []
      confidence = confidence.to_i
      confidence = 80 unless confidence.positive?

      @x_axis.each do |x_axis_date|
        end_date = if @chart_period_interval == 'day'
                     x_axis_date.end_of_day
                   elsif @chart_period_interval == 'week'
                     x_axis_date.end_of_week
                   else
                     x_axis_date.end_of_month
                   end

        demands_to_period = DemandsRepository.instance.throughput_to_projects_and_period([@project], @start_date, end_date)
        accumulated_leadtime_in_time << Stats::StatisticsService.instance.percentile(confidence, demands_to_period.map(&:leadtime_in_days))
      end

      [{ name: I18n.t('projects.general.leadtime', confidence: confidence), data: accumulated_leadtime_in_time, marker: { enabled: true } }]
    end

    private

    def build_x_axis
      @x_axis = TimeService.instance.days_between_of(@start_date, @end_date) if @chart_period_interval == 'day'
      @x_axis = TimeService.instance.weeks_between_of(@start_date, @end_date) if @chart_period_interval == 'week'
      @x_axis = TimeService.instance.months_between_of(@start_date, @end_date) if @chart_period_interval == 'month'
    end
  end
end
