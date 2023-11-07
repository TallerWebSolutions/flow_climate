# frozen_string_literal: true

module Types
  class TeamMemberConsolidationType < BaseObject
    field :consolidation_date, GraphQL::Types::ISO8601Date, null: false
    field :value_per_hour_performed, Float, null: false
  end
end
