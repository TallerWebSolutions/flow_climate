# frozen_string_literal: true

module Types
  class ProjectConsolidationType < Types::BaseObject
    field :id, ID, null: false
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :monte_carlo_weeks_min, Int, null: true
    field :monte_carlo_weeks_max, Int, null: true
    field :monte_carlo_weeks_std_dev, Int, null: true
    field :weeks_by_little_law, Float, null: false
    field :project, Types::ProjectType, null: false
    field :project_throughput, Float, null: false
    field :lead_time_min, Int, null: true
    field :lead_time_max, Int, null: true
    field :lead_time_p80, Int, null: true
    field :lead_time_std_dev, Int, null: true
    field :lead_time_histogram_bin_min, Float, null: false
    field :lead_time_histogram_bin_max, Float, null: false
    field :lead_time_average, Float, null: true
    field :demands_finished_ids, [Int], null: false
    field :lead_time_feature, Int, null: true
    field :lead_time_bug, Int, null: true
    field :lead_time_chore, Int, null: true
    field :lead_time_standard, Int, null: true
    field :lead_time_fixed_date, Int, null: true
    field :lead_time_expedite, Int, null: true
    field :team_based_operational_risk, Float, null: true
    field :lead_time_range_month, Float, null: false
    field :lead_time_min_month, Float, null: false
    field :lead_time_max_month, Float, null: false
    field :histogram_range, Float, null: false
    field :interquartile_range, Float, null: false
    field :lead_time_p25, Float, null: false
    field :lead_time_p75, Float, null: false
    field :total, [Int], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    delegate :project, to: :object

    def lead_time_min_month
      object.lead_time_min_month.to_f
    end

    def lead_time_max_month
      object.lead_time_max_month.to_f
    end

    def lead_time_histogram_bin_min
      object.lead_time_histogram_bin_min.to_f
    end

    def lead_time_histogram_bin_max
      object.lead_time_histogram_bin_max.to_f
    end
  end
end
