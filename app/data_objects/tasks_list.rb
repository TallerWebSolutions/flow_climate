# frozen_string_literal: true

class TasksList
  attr_reader :total_count, :total_delivered_count, :last_page, :total_pages, :tasks

  def initialize(total_count, total_delivered_count, last_page, total_pages, tasks)
    @total_count = total_count
    @total_delivered_count = total_delivered_count
    @last_page = last_page
    @total_pages = total_pages
    @tasks = tasks
  end
end
