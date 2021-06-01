# frozen_string_literal: true

module Highchart
  class ProjectsChartAdapter
    attr_reader :projects

    def initialize(projects)
      @projects = projects
    end

    def hours_per_project_in_period(start_date, end_date)
      hours_per_project_chart_data = {}
      hours_per_project_per_month = []
      date_interval = TimeService.instance.months_between_of(start_date, end_date)

      @projects.each do |project|
        date_interval.each { |date| hours_per_project_per_month << hours_to_month(date, project) }

        hours_per_project_chart_data[project.name] = hours_per_project_per_month
        hours_per_project_per_month = []
      end

      { x_axis: date_interval.map { |date| I18n.l(date, format: '%b/%Y') }, data: hours_per_project_chart_data }
    end

    private

    def hours_to_month(date, project)
      project.demands.to_end_dates(date.beginning_of_month, date.end_of_month).sum(&:total_effort).to_f
    end
  end
end
