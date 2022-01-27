# frozen_string_literal: true

module Highchart
  class TasksChartsAdapter
    attr_reader :x_axis, :tasks_in_chart, :throughput_chart_data, :creation_chart_data,
                :start_date, :end_date

    def initialize(tasks_ids, start_date, end_date)
      return if tasks_ids.blank?

      @tasks_in_chart = Task.where(id: tasks_ids).order(:created_date)
      @start_date = start_date
      @end_date = end_date
      @x_axis = TimeService.instance.weeks_between_of(start_date, end_date)

      build_creation_chart_data
      build_throughput_chart_data
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
  end
end
