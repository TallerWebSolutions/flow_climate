# frozen_string_literal: true

class ProjectsSummaryData
  attr_reader :projects, :total_flow_pressure

  def initialize(projects)
    @projects = projects
    @total_flow_pressure = projects&.sum(&:flow_pressure)
  end
end
