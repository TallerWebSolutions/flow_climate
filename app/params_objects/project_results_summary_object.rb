# frozen_string_literal: true

class ProjectResultsSummaryObject
  attr_reader :company, :project, :project_results, :total_hours_upstream, :total_hours_downstream, :total_hours, :total_throughput, :total_bugs_opened, :total_bugs_closed, :total_hours_bug, :avg_leadtime

  def initialize(company, project, project_results)
    @company = company
    @project = project
    @project_results = project_results.order(result_date: :desc)
    @total_hours_upstream = @project_results.sum(&:qty_hours_upstream)
    @total_hours_downstream = @project_results.sum(&:qty_hours_downstream)
    @total_hours = @project_results.sum(&:project_delivered_hours)
    @total_throughput = @project_results.sum(&:throughput)
    @total_bugs_opened = @project_results.sum(&:qty_bugs_opened)
    @total_bugs_closed = @project_results.sum(&:qty_bugs_closed)
    @total_hours_bug = @project_results.sum(&:qty_hours_bug)
    @avg_leadtime = @project_results.average(:leadtime)
  end
end
