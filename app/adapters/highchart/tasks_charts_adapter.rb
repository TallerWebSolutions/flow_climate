# frozen_string_literal: true

module Highchart
  class TasksChartsAdapter
    attr_reader :x_axis, :tasks_in_chart, :throughput_chart_data, :creation_chart_data,
                :completion_percentiles_on_time_chart_data, :start_date, :end_date

    def initialize(tasks_ids, start_date, end_date)
      return if tasks_ids.blank?

      @tasks_in_chart = Task.where(id: tasks_ids).order(:created_date)
      @start_date = start_date
      @end_date = end_date
      @x_axis = TimeService.instance.weeks_between_of(start_date, end_date)

      build_creation_chart_data
      build_throughput_chart_data
      build_tasks_completion_time_evolution
    end

    private

    def build_creation_chart_data
      @creation_chart_data = []
      @x_axis.each do |date|
        @creation_chart_data << @tasks_in_chart.where('tasks.created_date BETWEEN :start_date AND :end_date', start_date: date.beginning_of_week, end_date: date.end_of_week).count if date <= Time.zone.today.end_of_week
      end
    end

    def build_throughput_chart_data
      @throughput_chart_data = []
      @x_axis.each do |date|
        @throughput_chart_data << @tasks_in_chart.where('tasks.end_date BETWEEN :start_date AND :end_date', start_date: date.beginning_of_week, end_date: date.end_of_week).count if date <= Time.zone.today.end_of_week
      end
    end

    def build_tasks_completion_time_evolution
      completion_time_data = []
      accumulated_completion_time_data = []

      @x_axis.each do |chart_date|
        start_date = chart_date.beginning_of_week
        end_date = chart_date.end_of_week

        completion_time_data << read_completion_time_week_data(start_date, end_date)

        accumulated_completion_time_data << read_accumulated_data(end_date)
      end

      @completion_percentiles_on_time_chart_data = { y_axis: [{ name: I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence'), data: completion_time_data.map { |completion_time| completion_time.to_f / 1.day } }, { name: I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence_accumulated'), data: accumulated_completion_time_data.map { |completion_time| completion_time.to_f / 1.day } }] }
    end

    def read_accumulated_data(end_date)
      tasks_data_accumulated = @tasks_in_chart.finished(end_date)
      Stats::StatisticsService.instance.percentile(80, tasks_data_accumulated.map(&:seconds_to_complete))
    end

    def read_completion_time_week_data(start_date, end_date)
      week_tasks_data = @tasks_in_chart.where('tasks.end_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
      Stats::StatisticsService.instance.percentile(80, week_tasks_data.map(&:seconds_to_complete))
    end
  end
end
