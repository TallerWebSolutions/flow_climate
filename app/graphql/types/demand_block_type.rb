# frozen_string_literal: true

module Types
  class DemandBlockType < Types::BaseObject
    field :id, ID, null: false
    field :demand, Types::DemandType, null: false
    field :block_time, GraphQL::Types::ISO8601DateTime, null: false
    field :unblock_time, GraphQL::Types::ISO8601DateTime, null: true
  end
end
