# frozen_string_literal: true

module Types
  class ReplenishingConsolidationType < Types::BaseObject
    field :id, ID, null: false
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :project, Types::ProjectType, null: false

    field :team_throughput_data, [Int], null: true
    field :average_team_throughput, Int, null: true
    field :team_lead_time, Float, null: true
    field :team_wip, Int, null: true
  end
end
