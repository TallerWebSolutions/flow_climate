# frozen_string_literal: true

module Types
  class DemandTransitionType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :demand, Types::DemandType, null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime
    field :id, ID, null: false
    field :last_time_in, GraphQL::Types::ISO8601DateTime, null: false
    field :last_time_out, GraphQL::Types::ISO8601DateTime
    field :lock_version, Integer
    field :stage, Types::StageType, null: false
    field :team_member, Types::Teams::TeamMemberType
    field :transition_notified, Boolean, null: false
    field :transition_time_in_sec, Integer
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
