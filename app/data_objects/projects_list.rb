# frozen_string_literal: true

class ProjectsList < BaseAggregatorObject
  attr_reader :projects

  def initialize(projects, total_count, last_page, total_pages)
    super(total_count, last_page, total_pages)
    @projects = projects
  end
end
