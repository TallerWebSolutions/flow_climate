# frozen_string_literal: true

module Types
  class DemandEffortType < Types::BaseObject
    field :automatic_update, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :effort_money, String, null: true
    field :effort_value, Float, null: false
    field :finish_time_to_computation, GraphQL::Types::ISO8601DateTime, null: false
    field :id, ID, null: false
    field :main_effort_in_transition, Boolean, null: false
    field :management_percentage, Float, null: false
    field :member_role, String, null: true
    field :membership_effort_percentage, Float, null: true
    field :pairing_percentage, Float, null: false
    field :stage, String, null: true
    field :stage_percentage, Float, null: false
    field :start_time_to_computation, GraphQL::Types::ISO8601DateTime, null: false
    field :total_blocked, Float, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :who, String, null: true
    field :demand_id, Integer, null: false
    field :team, Types::Teams::TeamType, null: false
    field :demand_external_id, String, null: false
  end
end
