# frozen_string_literal: true

class TasksList
  attr_reader :total_count, :total_delivered_count, :tasks

  def initialize(total_count, total_delivered_count, tasks)
    @total_count = total_count
    @total_delivered_count = total_delivered_count
    @tasks = tasks
  end
end
