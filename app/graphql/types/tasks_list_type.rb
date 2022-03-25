# frozen_string_literal: true

module Types
  class TasksListType < Types::BaseObject
    field :total_count, Int, null: false
    field :total_delivered_count, Int, null: false
    field :last_page, Boolean, null: false
    field :total_pages, Int, null: false

    field :tasks, [Types::TaskType], null: false

    field :delivered_lead_time_p65, Float, null: false
    field :delivered_lead_time_p80, Float, null: false
    field :delivered_lead_time_p95, Float, null: false

    field :in_progress_lead_time_p65, Float, null: false
    field :in_progress_lead_time_p80, Float, null: false
    field :in_progress_lead_time_p95, Float, null: false

    field :tasks_charts, Types::Charts::TasksChartsType, null: false do
      argument :period, Types::Charts::ChartsPeriodsType, required: false
    end
    def tasks_charts(period: 'WEEKLY')
      start_date = object.tasks.map(&:created_date).min
      end_date = [object.tasks.map(&:created_date).max, object.tasks.map(&:end_date).max].compact.max
      ViewCharts::TasksCharts.new(object.tasks.map(&:id), start_date, end_date, period)
    end
  end
end
