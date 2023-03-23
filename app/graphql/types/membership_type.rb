# frozen_string_literal: true

module Types
  class MembershipType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :end_date, GraphQL::Types::ISO8601Date
    field :hours_per_month, Integer
    field :id, ID, null: false
    field :member_role, Integer, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :team_id, Integer, null: false
    field :team_member_id, Integer, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
