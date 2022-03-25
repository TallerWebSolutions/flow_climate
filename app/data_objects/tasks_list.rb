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

  def delivered_lead_time_p65
    Stats::StatisticsService.instance.percentile(65, completion_times)
  end

  def delivered_lead_time_p80
    Stats::StatisticsService.instance.percentile(80, completion_times)
  end

  def delivered_lead_time_p95
    Stats::StatisticsService.instance.percentile(95, completion_times)
  end

  def in_progress_lead_time_p65
    Stats::StatisticsService.instance.percentile(65, partial_completion_times)
  end

  def in_progress_lead_time_p80
    Stats::StatisticsService.instance.percentile(80, partial_completion_times)
  end

  def in_progress_lead_time_p95
    Stats::StatisticsService.instance.percentile(95, partial_completion_times)
  end

  private

  def completion_times
    return [] if @tasks.blank?

    @completion_times ||= @tasks.finished.map(&:seconds_to_complete)
  end

  def partial_completion_times
    return [] if @tasks.blank?

    @partial_completion_times ||= @tasks.open.map(&:partial_completion_time)
  end
end
