# frozen_string_literal: true

module Types
  class ProjectConsolidationType < Types::BaseObject
    field :id, ID, null: false
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :project, Types::ProjectType, null: false
    field :project_throughput, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    delegate :project, to: :object
  end
end
