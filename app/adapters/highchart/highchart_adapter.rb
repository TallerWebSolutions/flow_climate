# frozen_string_literal: true

module Highchart
  class HighchartAdapter
    attr_reader :all_projects, :all_projects_weeks, :all_projects_months, :all_projects_demands_ids,
                :active_projects_demands_ids, :minimum_date_limit, :upstream_operational_weekly_data, :downstream_operational_weekly_data

    def initialize(projects, period)
      @all_projects = projects
      build_minimum_date(period)
      @all_projects = search_projects_by_minimum_date(projects)
      @all_projects_demands_ids = @all_projects.map(&:kept_demands_ids).flatten
      build_all_projects_periods
      @upstream_operational_weekly_data = DemandsRepository.instance.operational_data_per_week_to_projects(@all_projects.map(&:id), false, charts_data_bottom_limit_date)
      @downstream_operational_weekly_data = DemandsRepository.instance.operational_data_per_week_to_projects(@all_projects.map(&:id), true, charts_data_bottom_limit_date)
    end

    def running_projects_in_the_list?
      return false if @all_projects.blank?

      @all_projects.map(&:status).flatten.include?('executing')
    end

    private

    def search_projects_by_minimum_date(projects)
      return projects if @minimum_date_limit.blank?

      projects.where('end_date IS NULL OR end_date >= :limit_date', limit_date: @minimum_date_limit)
    end

    def add_data_to_chart?(date)
      date.cwyear < Time.zone.today.cwyear || (date.cweek <= Time.zone.today.cweek && date.cwyear <= Time.zone.today.cwyear)
    end

    def add_month_data_to_chart?(date)
      date.year < Time.zone.today.year || (date.month <= Time.zone.today.month && date.year <= Time.zone.today.year)
    end

    def build_all_projects_periods
      min_date = @all_projects.map(&:start_date).min&.to_date
      min_date = [@all_projects.map(&:start_date).min, @minimum_date_limit].compact.max.to_date if @minimum_date_limit.present?
      max_date = @all_projects.maximum(:end_date)&.to_date
      @all_projects_weeks = TimeService.instance.weeks_between_of(min_date, max_date)
      @all_projects_months = TimeService.instance.months_between_of(min_date, max_date)
    end

    def throughput_chart_data
      upstream_result_data = []
      downstream_result_data = []
      @all_projects_weeks.each do |date|
        break unless add_data_to_chart?(date.to_date)

        upstream_keys_matching = @upstream_operational_weekly_data.keys.select { |key| key == date.to_date }
        upstream_result_data << upstream_operational_data_for_week(upstream_keys_matching, :throughput)

        downstream_keys_matching = @downstream_operational_weekly_data.keys.select { |key| key == date.to_date }
        downstream_result_data << downstream_operational_data_for_week(downstream_keys_matching, :throughput)
      end
      [{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: downstream_result_data }]
    end

    def upstream_operational_data_for_week(upstream_keys_matching, data_required)
      return @upstream_operational_weekly_data[upstream_keys_matching.first][data_required] if upstream_keys_matching.present? && @upstream_operational_weekly_data.try(:[], upstream_keys_matching.first).try(:[], data_required).present?

      0
    end

    def downstream_operational_data_for_week(downstream_keys_matching, data_required)
      return @downstream_operational_weekly_data[downstream_keys_matching.first][data_required] if downstream_keys_matching.present? && @downstream_operational_weekly_data.try(:[], downstream_keys_matching.first).try(:[], data_required).present?

      0
    end

    def build_minimum_date(period)
      base_date = @all_projects.map(&:end_date).flatten.max
      base_date = Time.zone.now if @all_projects.blank? || running_projects_in_the_list?
      @minimum_date_limit = TimeService.instance.limit_date_to_period(period, base_date)
    end

    def charts_data_bottom_limit_date
      @minimum_date_limit || all_projects_weeks.try(:[], 0) || Time.zone.today
    end
  end
end
