# frozen_string_literal: true

module Types
  class TeamMembersHourlyRateType < BaseObject
    field :period_date, GraphQL::Types::ISO8601Date, null: true
    field :value_per_hour_performed, Float, null: true
  end
end
