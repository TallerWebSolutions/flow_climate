# frozen_string_literal: true

module Types
  class ItemAssignmentType < Types::BaseObject
    field :assignment_for_role, Boolean
    field :assignment_notified, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :demand, Types::DemandType, null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime
    field :finish_time, GraphQL::Types::ISO8601DateTime
    field :id, ID, null: false
    field :item_assignment_effort, Float, null: false
    field :lock_version, Integer
    field :membership, Types::Teams::MembershipType, null: false
    field :pull_interval, Float
    field :start_time, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
