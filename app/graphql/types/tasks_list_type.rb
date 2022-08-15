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
    field :tasks_by_type, [Types::Charts::PieChartType], null: true

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

    def tasks_by_type
      tasks_to_chart = Task.where(id: object.tasks.map(&:id))
      tasks_chart = ViewCharts::TasksCharts.new(tasks_to_chart, start_date, end_date, 'weekly')
      tasks_chart.tasks_by_type
    end

    private

    def end_date
      [object.tasks.map(&:created_date).max, object.tasks.filter_map(&:end_date).max].compact.max
    end

    def start_date
      object.tasks.map(&:created_date).min
    end
  end
end
