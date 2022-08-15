# frozen_string_literal: true

module Types
  class TasksListType < Types::BaseObject
    field :last_page, Boolean, null: false
    field :total_count, Int, null: false
    field :total_delivered_count, Int, null: false
    field :total_pages, Int, null: false

    field :tasks, [Types::TaskType], null: false

    field :delivered_lead_time_p65, Float, null: false
    field :delivered_lead_time_p80, Float, null: false
    field :delivered_lead_time_p95, Float, null: false

    field :in_progress_lead_time_p65, Float, null: false
    field :in_progress_lead_time_p80, Float, null: false
    field :in_progress_lead_time_p95, Float, null: false

    field :completiontime_histogram_chart_data, Types::Charts::LeadTimeHistogramDataType, null: true
    field :control_chart, Types::Charts::ControlChartType, null: true
    field :tasks_by_project, [Types::Charts::SimpleChartType], null: true
    field :tasks_by_type, [Types::Charts::SimpleChartType], null: true

    field :tasks_charts, Types::Charts::TasksChartsType, null: false do
      argument :period, Types::Charts::ChartsPeriodsType, required: false
    end

    def tasks_charts(period: 'WEEKLY')
      ViewCharts::TasksCharts.new(object.tasks.map(&:id), start_date, end_date, period)
    end

    def completiontime_histogram_chart_data
      finished_tasks = Task.where(id: object.tasks.map(&:id)).finished
      Stats::StatisticsService.instance.completiontime_histogram_hash(finished_tasks.map(&:seconds_to_complete).map { |completiontime| completiontime.round(3) })
    end

    def control_chart
      tasks_finished = object_tasks.finished.order(end_date: :asc)
      completion_times = tasks_finished.map(&:seconds_to_complete)
      completion_time_p65 = Stats::StatisticsService.instance.percentile(65, completion_times)
      completion_time_p80 = Stats::StatisticsService.instance.percentile(80, completion_times)
      completion_time_p95 = Stats::StatisticsService.instance.percentile(95, completion_times)

      { x_axis: tasks_finished.map(&:external_id), lead_time_p65: completion_time_p65, lead_time_p80: completion_time_p80, lead_time_p95: completion_time_p95, lead_times: completion_times }
    end

    def tasks_by_type
      tasks_chart = ViewCharts::TasksCharts.new(object_tasks, start_date, end_date, 'weekly')
      tasks_chart.tasks_by_type
    end

    def tasks_by_project
      tasks_chart = ViewCharts::TasksCharts.new(object_tasks, start_date, end_date, 'weekly')
      tasks_chart.tasks_by_project
    end

    private

    def object_tasks
      Task.where(id: object.tasks.map(&:id))
    end

    def end_date
      [object.tasks.map(&:created_date).max, object.tasks.filter_map(&:end_date).max].compact.max
    end

    def start_date
      object.tasks.map(&:created_date).min
    end
  end
end
