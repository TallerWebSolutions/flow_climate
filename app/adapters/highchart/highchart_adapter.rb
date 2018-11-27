# frozen_string_literal: true

module Highchart
  class HighchartAdapter
    attr_reader :all_projects, :active_projects, :all_projects_weeks, :active_weeks, :all_projects_months, :active_months, :all_projects_demands_ids,
                :active_projects_demands_ids, :minimum_date_limit, :upstream_operational_weekly_data, :downstream_operational_weekly_data

    def initialize(projects, period)
      build_minimum_date(period)
      @all_projects = search_projects(projects)
      @all_projects_demands_ids = @all_projects.map(&:kept_demands_ids).flatten
      @active_projects = @all_projects.active
      @active_projects_demands_ids = @active_projects.map(&:kept_demands_ids).flatten
      build_all_projects_periods
      build_active_projects_periods
      @upstream_operational_weekly_data = DemandsRepository.instance.operational_data_per_week_to_projects(@all_projects.map(&:id), false, charts_data_bottom_limit_date)
      @downstream_operational_weekly_data = DemandsRepository.instance.operational_data_per_week_to_projects(@all_projects.map(&:id), true, charts_data_bottom_limit_date)
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
      @active_weeks = TimeService.instance.weeks_between_of(min_date, max_date)
      @active_months = TimeService.instance.months_between_of(min_date, max_date)
    end

    def build_all_projects_periods
      min_date = [@all_projects.minimum(:start_date), @minimum_date_limit].compact.max
      max_date = @all_projects.maximum(:end_date)
      @all_projects_weeks = TimeService.instance.weeks_between_of(min_date, max_date)
      @all_projects_months = TimeService.instance.months_between_of(min_date, max_date)
    end

    def throughput_chart_data
      upstream_result_data = []
      downstream_result_data = []
      @all_projects_weeks.each do |date|
        break unless add_data_to_chart?(date)

        upstream_keys_matching = @upstream_operational_weekly_data.keys.select { |key| key == date }
        upstream_result_data << upstream_operational_data_for_week(upstream_keys_matching, :throughput)

        downstream_keys_matching = @downstream_operational_weekly_data.keys.select { |key| key == date }
        downstream_result_data << downstream_operational_data_for_week(downstream_keys_matching, :throughput)
      end
      [{ name: I18n.t('projects.charts.throughput_per_week.stage_stream.upstream'), data: upstream_result_data }, { name: I18n.t('projects.charts.throughput_per_week.stage_stream.downstream'), data: downstream_result_data }]
    end

    def upstream_operational_data_for_week(upstream_keys_matching, data_required)
      if upstream_keys_matching.blank? || @upstream_operational_weekly_data[upstream_keys_matching.first][data_required].blank?
        0
      else
        @upstream_operational_weekly_data[upstream_keys_matching.first][:throughput]
      end
    end

    def downstream_operational_data_for_week(downstream_keys_matching, data_required)
      if downstream_keys_matching.blank? || @downstream_operational_weekly_data[downstream_keys_matching.first][data_required].blank?
        0
      else
        @downstream_operational_weekly_data[downstream_keys_matching.first][:throughput]
      end
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

    def charts_data_bottom_limit_date
      @minimum_date_limit || all_projects_weeks[0] || Time.zone.today
    end
  end
end
