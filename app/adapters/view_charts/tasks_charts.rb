# frozen_string_literal: true

module ViewCharts
  class TasksCharts
    attr_reader :start_date, :end_date, :x_axis, :throughput_array, :creation_array,
                :completion_percentiles_on_time_array, :accumulated_completion_percentiles_on_time_array,
                :tasks_by_type

    def initialize(tasks_ids, start_date, end_date, period)
      start_attributes
      return if tasks_ids.blank?

      @tasks_in_chart = Task.where(id: tasks_ids).order(:created_date)
      @start_date = start_date
      @end_date = end_date
      @period = period
      @x_axis = build_x_axis(end_date, start_date)

      build_creation_array
      build_throughput_array
      build_tasks_completion_time_evolution
      build_tasks_by_type
    end

    private

    attr_reader :tasks_in_chart, :period

    def start_attributes
      @x_axis = []
      @creation_array = []
      @throughput_array = []
      @completion_percentiles_on_time_array = []
      @accumulated_completion_percentiles_on_time_array = []
    end

    def build_x_axis(end_date, start_date)
      case period
      when 'DAILY'
        TimeService.instance.days_between_of(start_date, end_date)
      when 'MONTHLY'
        TimeService.instance.months_between_of(start_date, end_date)
      else
        TimeService.instance.weeks_between_of(start_date, end_date)
      end
    end

    def start_period(date)
      case period
      when 'DAILY'
        date.beginning_of_day
      when 'MONTHLY'
        date.beginning_of_month
      else
        date.beginning_of_week
      end
    end

    def end_period(date)
      case period
      when 'DAILY'
        date.end_of_day
      when 'MONTHLY'
        date.end_of_month
      else
        date.end_of_week
      end
    end

    def build_creation_array
      @creation_array = []
      @x_axis.each do |date|
        @creation_array << @tasks_in_chart.where('tasks.created_date BETWEEN :start_date AND :end_date', start_date: start_period(date), end_date: end_period(date)).count if date <= end_period(Time.zone.today)
      end
    end

    def build_throughput_array
      @throughput_array = []
      @x_axis.each do |date|
        @throughput_array << @tasks_in_chart.where('tasks.end_date BETWEEN :start_date AND :end_date', start_date: start_period(date), end_date: end_period(date)).count if date <= end_period(Time.zone.today)
      end
    end

    def build_tasks_completion_time_evolution
      @x_axis.each do |chart_date|
        start_date = start_period(chart_date)
        end_date = end_period(chart_date)

        @completion_percentiles_on_time_array << read_completion_time_week_data(start_date, end_date)

        @accumulated_completion_percentiles_on_time_array << read_accumulated_data(end_date)
      end
    end

    def read_accumulated_data(end_date)
      tasks_data_accumulated = @tasks_in_chart.finished(end_date)
      Stats::StatisticsService.instance.percentile(80, tasks_data_accumulated.map(&:seconds_to_complete))
    end

    def read_completion_time_week_data(start_date, end_date)
      week_tasks_data = @tasks_in_chart.where('tasks.end_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
      Stats::StatisticsService.instance.percentile(80, week_tasks_data.map(&:seconds_to_complete))
    end

    def build_tasks_by_type
      tasks_grouped = Task.where(id: @tasks_in_chart.map(&:id)).joins(:work_item_type).group('work_item_types.name').count.sort_by { |_key, value| value }.reverse.to_h

      @tasks_by_type = []
      tasks_grouped.each { |type_grouped, group_count| @tasks_by_type << { name: type_grouped, y: group_count } }
    end
  end
end
