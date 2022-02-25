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
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    delegate :project, to: :object
  end
end
