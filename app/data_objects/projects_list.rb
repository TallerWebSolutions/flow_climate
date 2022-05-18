# frozen_string_literal: true

class ProjectsList
  attr_reader :total_count, :last_page, :total_pages, :projects

  def initialize(projects, total_count, last_page, total_pages)
    @projects = projects
    @total_count = total_count
    @last_page = last_page
    @total_pages = total_pages
  end
end
