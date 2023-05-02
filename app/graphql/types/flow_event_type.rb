# frozen_string_literal: true

module Types
  class FlowEventType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime
    field :event_date, GraphQL::Types::ISO8601Date, null: false
    field :event_description, String, null: false
    field :event_end_date, GraphQL::Types::ISO8601Date
    field :event_size, Integer, null: false
    field :event_type, String, null: false
    field :id, ID, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user_id, Integer
  end
end
