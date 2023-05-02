# frozen_string_literal: true

module Types
  class ServiceDeliveryReviewActionItemType < Types::BaseObject
    field :action_type, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :deadline, GraphQL::Types::ISO8601Date, null: false
    field :description, String, null: false
    field :done_date, GraphQL::Types::ISO8601Date
    field :id, ID, null: false
    field :membership, Types::Teams::MembershipType, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
