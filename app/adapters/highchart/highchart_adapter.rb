# frozen_string_literal: true

module Highchart
  class HighchartAdapter
    attr_reader :all_projects, :active_projects, :all_projects_weeks, :active_weeks, :all_projects_months, :active_months, :minimum_date_limit

    def initialize(projects, period)
      build_minimum_date(period)
      @all_projects = search_projects(projects)
      @active_projects = @all_projects.active
      build_all_projects_periods
      build_active_projects_periods
    end

    private

    def search_projects(projects)
      return projects if @minimum_date_limit.blank?
      projects.where('end_date IS NULL OR end_date >= :limit_date', limit_date: @minimum_date_limit)
    end

    def add_data_to_chart?(date)
      date.cwyear < Time.zone.today.cwyear || (date.cweek <= Time.zone.today.cweek && date.cwyear <= Time.zone.today.cwyear)
    end

    def add_month_data_to_chart?(date)
      date.year < Time.zone.today.year || (date.month <= Time.zone.today.month && date.year <= Time.zone.today.year)
    end

    def build_active_projects_periods
      min_date = [active_projects.minimum(:start_date), @minimum_date_limit].compact.max
      max_date = active_projects.maximum(:end_date)
      @active_weeks = build_weeks_array(min_date, max_date)
      @active_months = build_months_array(min_date, max_date)
    end

    def build_all_projects_periods
      min_date = [all_projects.minimum(:start_date), @minimum_date_limit].compact.max
      max_date = all_projects.maximum(:end_date)
      @all_projects_weeks = build_weeks_array(min_date, max_date)
      @all_projects_months = build_months_array(min_date, max_date)
    end

    def build_weeks_array(min_date, max_date)
      array_of_weeks = []

      return [] if min_date.blank? || max_date.blank?

      while min_date <= max_date
        array_of_weeks << min_date.beginning_of_week
        min_date += 7.days
      end

      array_of_weeks
    end

    def build_months_array(min_date, max_date)
      array_of_months = []

      return [] if min_date.blank? || max_date.blank?

      while min_date <= max_date
        array_of_months << Date.new(min_date.year, min_date.month, 1)
        min_date += 1.month
      end

      array_of_months
    end

    def throughput_chart_data(downstream_th_weekly_data, upstream_th_weekly_data)
      upstream_result_data = []
      downstream_result_data = []
      @all_projects_weeks.each do |date|
        break unless add_data_to_chart?(date)
        upstream_keys_matching = upstream_th_weekly_data.keys.select { |key| key == date }
        upstream_result_data << (upstream_th_weekly_data[upstream_keys_matching.first] || 0)

        downstream_keys_matching = downstream_th_weekly_data.keys.select { |key| key == date }
        downstream_result_data << (downstream_th_weekly_data[downstream_keys_matching.first] || 0)
      end
      [{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: downstream_result_data }]
    end

    def build_minimum_date(period)
      @minimum_date_limit = if period == 'all'
                              nil
                            elsif period == 'quarter'
                              3.months.ago.to_date
                            else
                              1.month.ago.to_date
                            end
    end

    def lower_limit_date_to_charts
      @all_projects_weeks[0] || Time.zone.today
    end

    def upper_limit_date_to_charts
      @all_projects_weeks.last || Time.zone.today
    end
  end
end
