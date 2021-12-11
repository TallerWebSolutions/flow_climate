# frozen_string_literal: true

module Types
  class ReplenishingConsolidationType < Types::BaseObject
    field :id, ID, null: false
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :project, Types::ProjectType, null: false

    delegate :project, to: :object

    delegate :team_throughput_data, to: :object
  end
end
