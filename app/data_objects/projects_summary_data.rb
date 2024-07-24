# frozen_string_literal: true

class ProjectsSummaryData
  attr_reader :projects, :total_flow_pressure

  def initialize(projects)
    @projects = projects
    @total_flow_pressure = projects&.sum(&:flow_pressure)
  end

  def discovered_scope
    return {} if @projects.blank?

    discovered_after_project_starts = demands.where(created_date: min_date..)

    discovered_before_project_starts = demands - discovered_after_project_starts

    { discovered_after: discovered_after_project_starts, discovered_before_project_starts: discovered_before_project_starts }
  end

  private

  def demands
    return [] if @projects.blank?

    @demands ||= Demand.kept.where(id: @projects.map(&:demands).flatten.map(&:id)).order(:created_date)
  end

  def min_date
    @min_date ||= @projects.map(&:start_date).min
  end
end
