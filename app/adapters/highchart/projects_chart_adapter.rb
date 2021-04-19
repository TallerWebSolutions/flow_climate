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
      consolidation_date = date
      consolidation_date = [project.end_date, date].min if project.end_date.month == date.month
      consolidation_date = [consolidation_date, Time.zone.today].min

      project_consolidation = project.project_consolidations.where(consolidation_date: consolidation_date).last
      return project_consolidation.project_throughput_hours_in_month.to_f if project_consolidation.present?

      0
    end
  end
end
