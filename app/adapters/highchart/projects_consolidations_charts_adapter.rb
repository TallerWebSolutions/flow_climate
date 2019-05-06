# frozen_string_literal: true

module Highchart
  class ProjectsConsolidationsChartsAdapter
    attr_reader :projects_consolidations

    def initialize(projects_consolidations, start_date, end_date)
      @projects_consolidations = projects_consolidations.where('consolidation_date BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
    end

    def lead_time_data_range_evolution
      x_axis = @projects_consolidations.map(&:consolidation_date)
      y_axis =
        [
          { name: I18n.t('charts.lead_time_data_range_evolution.total_range'), data: @projects_consolidations.map { |consolidation| (consolidation.total_range / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_data_range_evolution.total_range_max'), data: @projects_consolidations.map { |consolidation| (consolidation.lead_time_max / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_data_range_evolution.total_range_min'), data: @projects_consolidations.map { |consolidation| (consolidation.lead_time_min / 86_400).to_f }, marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end

    def lead_time_histogram_data_range_evolution
      x_axis = @projects_consolidations.map(&:consolidation_date)
      y_axis =
        [
          { name: I18n.t('charts.lead_time_histogram_data_range_evolution.total_range'), data: @projects_consolidations.map { |consolidation| (consolidation.histogram_range / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_histogram_data_range_evolution.total_range_max'), data: @projects_consolidations.map { |consolidation| (consolidation.lead_time_histogram_bin_max / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_histogram_data_range_evolution.total_range_min'), data: @projects_consolidations.map { |consolidation| (consolidation.lead_time_histogram_bin_min / 86_400).to_f }, marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end

    def lead_time_interquartile_data_range_evolution
      x_axis = @projects_consolidations.map(&:consolidation_date)
      y_axis =
        [
          { name: I18n.t('charts.lead_time_interquartile_data_range_evolution.total_range'), data: @projects_consolidations.map { |consolidation| (consolidation.interquartile_range / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_interquartile_data_range_evolution.percentile_25'), data: @projects_consolidations.map { |consolidation| (consolidation.lead_time_p25 / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_interquartile_data_range_evolution.percentile_75'), data: @projects_consolidations.map { |consolidation| (consolidation.lead_time_p75 / 86_400).to_f }, marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end

    def lead_time_interquartile_histogram_range_evolution
      x_axis = @projects_consolidations.map(&:consolidation_date)
      y_axis =
        [
          { name: I18n.t('charts.lead_time_interquartile_histogram_range_evolution.total_range'), data: @projects_consolidations.map { |consolidation| ((consolidation.histogram_range - consolidation.interquartile_range) / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_interquartile_histogram_range_evolution.interquartile'), data: @projects_consolidations.map { |consolidation| (consolidation.interquartile_range / 86_400).to_f }, marker: { enabled: true } },
          { name: I18n.t('charts.lead_time_interquartile_histogram_range_evolution.histogram'), data: @projects_consolidations.map { |consolidation| (consolidation.histogram_range / 86_400).to_f }, marker: { enabled: true } }
        ]

      { x_axis: x_axis, y_axis: y_axis }
    end
  end
end
