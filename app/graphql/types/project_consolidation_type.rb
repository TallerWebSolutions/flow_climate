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
    field :lead_time_histogram_bin_min, Int, null: true
    field :lead_time_histogram_bin_max, Int, null: true
    field :lead_time_average, Float, null: true
    field :demands_finished_ids, [Int], null: false
    field :lead_time_feature, Int, null: true
    field :lead_time_bug, Int, null: true
    field :lead_time_chore, Int, null: true
    field :lead_time_standard, Int, null: true
    field :lead_time_fixed_date, Int, null: true
    field :lead_time_expedite, Int, null: true    

    field :total, [Int], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    delegate :project, to: :object
  end
end
