# frozen_string_literal: true

module Types
  class TeamMemberConsolidationType < BaseObject
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :hour_value_expected, Float, null: false
    field :hour_value_realized, Float, null: false
  end
end
