# frozen_string_literal: true

module Types
  class DemandEffortType < Types::BaseObject
    field :automatic_update, Boolean, null: false
    field :id, ID, null: false
    field :main_effort_in_transition, Boolean, null: false
    field :start_time_to_computation, GraphQL::Types::ISO8601DateTime, null: false
    field :finish_time_to_computation, GraphQL::Types::ISO8601DateTime, null: false
    field :effort_value, Float, null: false
    field :management_percentage, Float, null: false
    field :pairing_percentage, Float, null: false
    field :stage_percentage, Float, null: false
    field :total_blocked, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :stage, String, null: true
    field :who, String, null: true
    field :member_role, String, null: true
  end
end
