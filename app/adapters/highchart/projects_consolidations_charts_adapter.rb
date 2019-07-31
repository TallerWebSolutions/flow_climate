# frozen_string_literal: true

module Highchart
  class ProjectsConsolidationsChartsAdapter
    include DateHelper

    attr_reader :projects_consolidations, :x_axis

    def initialize(projects_consolidations, start_date, end_date)
      @projects_consolidations = projects_consolidations.where('consolidation_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
      @x_axis = @projects_consolidations.map(&:consolidation_date).uniq
    end

    def lead_time_data_range_evolution
      y_axis_data = build_y_axis(@x_axis, :total_lead_time_range, :lead_time_max, :lead_time_min)

      y_axis =
        [
          { name: I18n.t('charts.lead_time_data_range_evolution.total_range'), data: y_axis_data[:ranges], marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_data_range_evolution.total_range_max'), data: y_axis_data[:array_of_field_max], marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_data_range_evolution.total_range_min'), data: y_axis_data[:array_of_field_min], marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end

    def lead_time_histogram_data_range_evolution
      y_axis_data = build_y_axis(@x_axis, :histogram_range, :lead_time_histogram_bin_max, :lead_time_histogram_bin_min)

      y_axis =
        [
          { name: I18n.t('charts.lead_time_histogram_data_range_evolution.total_range'), data: y_axis_data[:ranges], marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_histogram_data_range_evolution.total_range_max'), data: y_axis_data[:array_of_field_max], marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_histogram_data_range_evolution.total_range_min'), data: y_axis_data[:array_of_field_min], marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end

    def lead_time_interquartile_data_range_evolution
      y_axis_data = build_y_axis(@x_axis, :interquartile_range, :lead_time_p75, :lead_time_p25)

      y_axis =
        [
          { name: I18n.t('charts.lead_time_interquartile_data_range_evolution.total_range'), data: y_axis_data[:ranges], marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_interquartile_data_range_evolution.percentile_25'), data: y_axis_data[:array_of_field_min], marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_interquartile_data_range_evolution.percentile_75'), data: y_axis_data[:array_of_field_max], marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end

    private

    def build_y_axis(x_axis, range, field_max, field_min)
      ranges = []
      array_of_field_max = []
      array_of_field_min = []
      x_axis.each do |date|
        consolidations_in_week = @projects_consolidations.where(consolidation_date: date)
        ranges << seconds_to_day(consolidations_in_week.map(&range).max)
        array_of_field_max << seconds_to_day(consolidations_in_week.map(&field_max).compact.max)
        array_of_field_min << seconds_to_day(consolidations_in_week.map(&field_min).compact.max)
      end
      { ranges: ranges, array_of_field_max: array_of_field_max, array_of_field_min: array_of_field_min }
    end
  end
end
